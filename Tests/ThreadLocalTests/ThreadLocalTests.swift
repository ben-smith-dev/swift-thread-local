import Testing
import ThreadLocal

@Suite
private struct ThreadLocalTests {
    @Test(arguments: [nil, 0, 1] as [Int?])
    private func getProvidesExpectedDefaultValue(expectedDefaultValue: Int?) {
        let threadLocalValue = ThreadLocal<Int?>(defaultValue: expectedDefaultValue)

        #expect(threadLocalValue.get() == expectedDefaultValue)
    }

    @Test
    private func emptyInitializerForOptionalValueHasNilDefaultValue() {
        let threadLocalValue = ThreadLocal<Int?>()

        #expect(threadLocalValue.get() == nil)
    }

    @Test(arguments: [nil, 0, 1] as [Int?])
    private func getProvidesExpectedStoredValue(expectedValue: Int?) {
        let threadLocalValue = ThreadLocal<Int?>()

        threadLocalValue.set(expectedValue)

        #expect(threadLocalValue.get() == expectedValue)
    }

    @Test
    private func eachThreadGetsItsOwnDefaultValue() async {
        let threadLocalValue = ThreadLocal(defaultValue: Ref())

        let thread1DefaultValue: Ref = await withUniqueThread { threadLocalValue.get() }
        let thread2DefaultValue: Ref = await withUniqueThread { threadLocalValue.get() }

        #expect(thread1DefaultValue !== thread2DefaultValue)
    }

    @Test
    private func sequentialGetCallsReturnSameDefaultValueInstance() {
        let threadLocalValue = ThreadLocal(defaultValue: Ref())

        // swiftlint:disable:next identical_operands
        #expect(threadLocalValue.get() === threadLocalValue.get())
    }
}

// MARK: Mocks

extension ThreadLocalTests {
    private final class Ref: Sendable {
        // Empty.
    }
}
