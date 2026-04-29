public struct ReadonlyThreadLocal<Value>: ~Copyable {
    private let storage = ThreadLocalStorage<Value>()
    private let valueProvider: @Sendable () -> Value

    public init(value valueProvider: @autoclosure @escaping @Sendable () -> Value) {
        self.valueProvider = valueProvider
    }

    @available(*, noasync)
    public func get() -> Value {
        if let value: Value = self.storage.get() {
            return value
        }

        let value: Value = self.valueProvider()
        self.storage.set(value)

        return value
    }
}

// MARK: Sendable Conformance

extension ReadonlyThreadLocal: Sendable where Value: Sendable {
    // Empty.
}
