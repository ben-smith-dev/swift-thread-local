public struct ScopedThreadLocal<Value>: ~Copyable {
    private let storage = ThreadLocalStorage<Value>()
    private let defaultValueProvider: @Sendable () -> Value

    public init(defaultValue defaultValueProvider: @autoclosure @escaping @Sendable () -> Value) {
        self.defaultValueProvider = defaultValueProvider
    }

    @available(*, noasync)
    public func get() -> Value {
        if let value: Value = self.storage.get() {
            return value
        }

        let defaultValue: Value = self.defaultValueProvider()
        self.storage.set(defaultValue)

        return defaultValue
    }

    @available(*, noasync)
    public func withValue<Success: ~Copyable, Failure: Error>(
        _ value: Value,
        operation: () throws(Failure) -> Success
    ) throws(Failure) -> Success {
        let previousValue: Value? = self.storage.get()
        defer {
            if let previousValue {
                self.storage.set(previousValue)
            } else {
                self.storage.clear()
            }
        }

        self.storage.set(value)

        return try operation()
    }
}

// MARK: Nil Default Value Initializer

extension ScopedThreadLocal where Value: ExpressibleByNilLiteral & SendableMetatype {
    public init() {
        self.init(defaultValue: nil)
    }
}

// MARK: Sendable Conformance

extension ScopedThreadLocal: Sendable where Value: Sendable {
    // Empty.
}
