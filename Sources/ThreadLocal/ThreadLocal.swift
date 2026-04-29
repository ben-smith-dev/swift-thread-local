public struct ThreadLocal<Value>: ~Copyable {
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
    public func set(_ value: Value) {
        self.storage.set(value)
    }
}

// MARK: Nil Default Value Initializer

extension ThreadLocal where Value: ExpressibleByNilLiteral & SendableMetatype {
    public init() {
        self.init(defaultValue: nil)
    }
}

// MARK: Sendable Conformance

extension ThreadLocal: Sendable where Value: Sendable {
    // Empty.
}
