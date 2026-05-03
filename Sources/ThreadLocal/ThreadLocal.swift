/// A thread-local value with explicit bindings.
///
/// - Important: Must be declared as a nonisolated static property or nonisolated global constant.
///
/// - Seealso:
///   ``ReadonlyThreadLocal``
///   ``ScopedThreadLocal``
public struct ThreadLocal<Value>: ~Copyable {
    private let storage = ThreadLocalStorage<Value>()
    private let defaultValueProvider: @Sendable () -> Value

    /// - Parameter defaultValueProvider: The default value when no value has been bound.
    ///   Will be lazily evaluated **at most** once per thread.
    public init(defaultValue defaultValueProvider: @autoclosure @escaping @Sendable () -> Value) {
        self.defaultValueProvider = defaultValueProvider
    }

    /// Gets the value bound to the current thread.
    ///
    /// - Important: Due to async suspension points causing possible executor switches,
    ///   ``get()`` is restricted to synchronous contexts to avoid unexpected behavior.
    ///
    /// - Remark: If no value is bound, the `defaultValue` is evaluated, bound to the current
    ///   thread, and returned.
    ///
    /// - Returns: The bound value for the current thread, or if no value is bound, the `defaultValue`.
    @available(*, noasync)
    public func get() -> Value {
        if let value: Value = self.storage.get() {
            return value
        }

        let defaultValue: Value = self.defaultValueProvider()
        self.storage.set(defaultValue)

        return defaultValue
    }

    /// Binds a value to the current thread.
    ///
    /// The value persists for the lifetime of the thread or until explicitly overwritten by ``set(_:)``.
    ///
    /// - Important: Due to async suspension points causing possible executor switches,
    ///   ``set(_:)`` is restricted to synchronous contexts to avoid unexpected behavior.
    @available(*, noasync)
    public func set(_ value: Value) {
        self.storage.set(value)
    }
}

// MARK: Nil Default Value Initializer

extension ThreadLocal where Value: ExpressibleByNilLiteral & SendableMetatype {
    /// Initializes a ``ThreadLocal/ThreadLocal`` with a `nil` default value.
    ///
    /// - Note: Equivalent to:
    ///   ```swift
    ///   ThreadLocal(defaultValue: nil)
    ///   ```
    public init() {
        self.init(defaultValue: nil)
    }
}

// MARK: Sendable Conformance

extension ThreadLocal: Sendable where Value: Sendable {
    // Empty.
}
