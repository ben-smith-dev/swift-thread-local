import Testing
import ThreadLocal

@Suite
private struct ScopedThreadLocalTests {
    @Test(arguments: [nil, 0, 1] as [Int?])
    private func getProvidesExpectedDefaultValue(expectedDefaultValue: Int?) {
        let threadLocalValue = ScopedThreadLocal<Int?>(defaultValue: expectedDefaultValue)

        #expect(threadLocalValue.get() == expectedDefaultValue)
    }

    @Test
    private func emptyInitializerForOptionalValueHasNilDefaultValue() {
        let threadLocalValue = ScopedThreadLocal<Int?>()

        #expect(threadLocalValue.get() == nil)
    }

    @Test
    private func withValueProperlyScopesValue() throws {
        let defaultValue: Int = 0
        let scopedValue: Int = 1
        let threadLocalValue = ScopedThreadLocal(defaultValue: defaultValue)

        try threadLocalValue.withValue(scopedValue) {
            try #require(threadLocalValue.get() == scopedValue)
        }

        #expect(threadLocalValue.get() == defaultValue)
    }

    @Test
    private func withValueProperlyScopesValueAfterUnscopedGet() throws {
        let defaultValue: Int = 0
        let scopedValue: Int = 1
        let threadLocalValue = ScopedThreadLocal(defaultValue: defaultValue)

        try #require(threadLocalValue.get() == defaultValue)

        try threadLocalValue.withValue(scopedValue) {
            try #require(threadLocalValue.get() == scopedValue)
        }

        #expect(threadLocalValue.get() == defaultValue)
    }

    @Test
    private func withValueProperlyScopesDeeplyNestedValue() throws {
        let defaultValue: Int = 0
        let scopedValue: Int = 1
        let nestedScopeValue: Int = 2
        let threadLocalValue = ScopedThreadLocal(defaultValue: defaultValue)

        try #require(threadLocalValue.get() == defaultValue)

        try threadLocalValue.withValue(scopedValue) {
            try #require(threadLocalValue.get() == scopedValue)

            try threadLocalValue.withValue(nestedScopeValue) {
                try #require(threadLocalValue.get() == nestedScopeValue)
            }

            try #require(threadLocalValue.get() == scopedValue)
        }

        #expect(threadLocalValue.get() == defaultValue)
    }

    @Test
    private func eachThreadGetsItsOwnDefaultValue() async {
        let threadLocalValue = ScopedThreadLocal(defaultValue: Ref())

        let thread1DefaultValue: Ref = await withUniqueThread { threadLocalValue.get() }
        let thread2DefaultValue: Ref = await withUniqueThread { threadLocalValue.get() }

        #expect(thread1DefaultValue !== thread2DefaultValue)
    }
}

// MARK: Mocks

extension ScopedThreadLocalTests {
    private final class Ref: Sendable {
        // Empty.
    }
}
