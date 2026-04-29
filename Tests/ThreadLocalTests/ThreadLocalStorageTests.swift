import Testing
@testable import ThreadLocal

import class Foundation.Thread

@Suite
private struct ThreadLocalStorageTests {
    @Test
    private func getReturnsNilIfNoValueIsStored() {
        let storage = ThreadLocalStorage<Int>()

        #expect(storage.get() == nil)
    }

    @Test
    private func setOverwritesPreviousValue() throws {
        let previousValue: Int = 0
        let newValue: Int = 1
        let storage = ThreadLocalStorage<Int>()

        try #require(previousValue != newValue)

        storage.set(previousValue)

        try #require(storage.get() == previousValue)

        storage.set(newValue)

        #expect(storage.get() == newValue)
    }

    @Test(arguments: 0...5)
    private func getReturnsExpectedStoredValue(expectedValue: Int) {
        let storage = ThreadLocalStorage<Int>()

        storage.set(expectedValue)

        #expect(storage.get() == expectedValue)
    }

    @Test
    private func sequentialGetProvidesSameValue() throws {
        let expectedValue: Int = 0
        let storage = ThreadLocalStorage<Int>()

        storage.set(expectedValue)

        for _ in 0..<5 {
            try #require(storage.get() == expectedValue)
        }
    }

    @Test
    private func storageHoldsStrongReferenceToClass() throws {
        let storage = ThreadLocalStorage<Ref>()

        weak let weakRef: Ref?
        do {
            let tempStrongRef = Ref()
            weakRef = tempStrongRef
            storage.set(tempStrongRef)
        }

        try #require(weakRef != nil)
        try #require(storage.get() != nil)

        #expect(storage.get() === weakRef)
    }

    @Test
    private func referenceIsReleasedIfValueIsOverwritten() throws {
        let storage = ThreadLocalStorage<Ref>()

        weak let weakRef: Ref?
        do {
            let tempStrongRef = Ref()
            weakRef = tempStrongRef
            storage.set(tempStrongRef)
        }

        try #require(weakRef != nil)
        try #require(storage.get() != nil)

        storage.set(Ref())

        #expect(weakRef == nil)
    }

    @Test
    private func clearReleasesStoredValue() throws {
        let storage = ThreadLocalStorage<Ref>()

        weak let weakRef: Ref?
        do {
            let tempStrongRef = Ref()
            weakRef = tempStrongRef
            storage.set(tempStrongRef)
        }

        try #require(weakRef != nil)
        try #require(storage.get() != nil)

        storage.clear()

        #expect(storage.get() == nil)
        #expect(weakRef == nil)
    }

    @Test
    private func setRestoresClearedValue() throws {
        let newValue: Int = 0
        let storage = ThreadLocalStorage<Int>()

        try #require(storage.get() == nil)

        storage.clear()

        try #require(storage.get() == nil)

        storage.set(newValue)

        #expect(storage.get() == newValue)
    }

    @Test
    private func separateStorageInstancesHaveSeparateValuesOnSameThread() throws {
        let storage1Value: Int = 1
        let storage2Value: Int = 2
        let storage1 = ThreadLocalStorage<Int>()
        let storage2 = ThreadLocalStorage<Int>()

        storage1.set(storage1Value)
        storage2.set(storage2Value)

        try #require(storage1.get() == storage1Value)
        try #require(storage2.get() == storage2Value)

        #expect(storage1.get() != storage2.get())
    }
}

// MARK: Threading Tests

extension ThreadLocalStorageTests {
    @Test
    private func storedValueDoesNotLeakToOtherThread() async throws {
        let storage = ThreadLocalStorage<Ref>()

        try await withUniqueThread {
            let threadValue = Ref()
            storage.set(threadValue)
            try #require(storage.get() === threadValue)
        }

        try await withUniqueThread {
            try #require(storage.get() == nil)
        }
    }

    @Test
    private func clearingThreadDoesNotClearOtherThread() async throws {
        let mainThreadValue: Int = 0
        let storage = ThreadLocalStorage<Int>()

        try await withMainThread {
            try #require(storage.get() == nil)
            storage.set(mainThreadValue)
            try #require(storage.get() == mainThreadValue)
        }

        try await withUniqueThread {
            storage.clear()
            try #require(storage.get() == nil)
        }

        try await withMainThread {
            try #require(storage.get() == mainThreadValue)
        }
    }

    @Test
    private func threadLocalValueIsReleasedAfterThreadExits() async throws {
        let storage = ThreadLocalStorage<Ref>()

        let weakBox: WeakBox<Ref> = try await withFinalizingUniqueThread {
            try #require(storage.get() == nil)

            storage.set(Ref())
            let weakBox = WeakBox(value: storage.get())

            try #require(weakBox.value != nil)

            return weakBox
        }

        #expect(weakBox.value == nil)
    }
}

// MARK: Mocks

extension ThreadLocalStorageTests {
    private final class Ref: Sendable {
        // Empty.
    }
}

// MARK: Helpers

extension ThreadLocalStorageTests {
    private struct WeakBox<Value: AnyObject & Sendable>: Sendable {
        public weak let value: Value?
    }
}
