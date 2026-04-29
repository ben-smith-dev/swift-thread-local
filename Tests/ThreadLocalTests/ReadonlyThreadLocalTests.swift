import Testing
import ThreadLocal

@Suite
private struct ReadonlyThreadLocalTests {
    @Test
    private func getReturnsExpectedValue() {
        let expectedValue = Ref()
        let threadLocalValue = ReadonlyThreadLocal(value: expectedValue)

        #expect(threadLocalValue.get() === expectedValue)
    }

    @Test
    private func sequentialGetReturnsExpectedValue() {
        let threadLocalValue = ReadonlyThreadLocal(value: Ref())

        let expectedValue: Ref = threadLocalValue.get()

        #expect(threadLocalValue.get() === expectedValue)
        #expect(threadLocalValue.get() === expectedValue)
    }
}

// MARK: Mocks

extension ReadonlyThreadLocalTests {
    private final class Ref: Sendable {
        // Empty.
    }
}
