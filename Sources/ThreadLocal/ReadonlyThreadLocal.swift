/// A readonly thread-local value.
///
/// - Important: Must be declared as a nonisolated static property or nonisolated global constant.
///
/// - Seealso:
///   ``ScopedThreadLocal``
///   ``ThreadLocal/ThreadLocal``
public struct ReadonlyThreadLocal<Value>: ~Copyable {
    private let storage = ThreadLocalStorage<Value>()
    private let valueProvider: @Sendable () -> Value

    /// - Parameter valueProvider: The value to bind to a thread. Will be lazily evaluated
    ///   **at most** once per thread and cached for that thread's lifetime.
    public init(value valueProvider: @autoclosure @escaping @Sendable () -> Value) {
        self.valueProvider = valueProvider
    }

    /// Gets the value bound to the current thread.
    ///
    /// - Important: Due to async suspension points causing possible executor switches,
    ///   ``get()`` is restricted to synchronous contexts to avoid unexpected behavior.
    ///
    /// - Remark: The `value` is evaluated on first access, bound to the current thread, and then returned.
    ///
    /// - Returns: The bound value for the current thread.
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
