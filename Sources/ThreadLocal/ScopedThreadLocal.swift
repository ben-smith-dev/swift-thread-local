/// A thread-local value supporting scoped overrides.
///
/// - Important: Must be declared as a nonisolated static property or nonisolated global constant.
///
/// - Seealso:
///   ``ReadonlyThreadLocal``
///   ``ThreadLocal/ThreadLocal``
public struct ScopedThreadLocal<Value>: ~Copyable {
    private let storage = ThreadLocalStorage<Value>()
    private let defaultValueProvider: @Sendable () -> Value

    /// - Parameter defaultValueProvider: The default value to bind to a thread's global scope.
    ///   Will be lazily evaluated **at most** once per thread and cached for that thread's lifetime.
    public init(defaultValue defaultValueProvider: @autoclosure @escaping @Sendable () -> Value) {
        self.defaultValueProvider = defaultValueProvider
    }

    /// Gets the value bound to the current thread's scope.
    ///
    /// - Important: Due to async suspension points causing possible executor switches,
    ///   ``get()`` is restricted to synchronous contexts to avoid unexpected behavior.
    ///
    /// - Remark: If in the thread's global scope, then the `defaultValue` is evaluated and cached.
    ///
    /// - Returns: The scoped value for the current thread, or if in the global scope, the `defaultValue`.
    @available(*, noasync)
    public func get() -> Value {
        if let value: Value = self.storage.get() {
            return value
        }

        let defaultValue: Value = self.defaultValueProvider()
        self.storage.set(defaultValue)

        return defaultValue
    }

    /// Binds a value to a new scope for the duration of the operation.
    ///
    /// Creates a new scope on the current thread where ``get()`` returns the specified value.
    /// The previous scope's value is automatically restored when the operation completes or throws.
    ///
    /// Nested calls create a stack of scopes, with ``get()`` always returning the value from the
    /// innermost (most recent) scope.
    ///
    /// - Important: Due to async suspension points causing possible executor switches,
    ///   ``withValue(_:operation:)`` is restricted to synchronous contexts to avoid unexpected behavior.
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
    /// Initializes a ``ScopedThreadLocal`` with a `nil` default value.
    ///
    /// - Note: Equivalent to:
    ///   ```swift
    ///   ScopedThreadLocal(defaultValue: nil)
    ///   ```
    public init() {
        self.init(defaultValue: nil)
    }
}

// MARK: Sendable Conformance

extension ScopedThreadLocal: Sendable where Value: Sendable {
    // Empty.
}
