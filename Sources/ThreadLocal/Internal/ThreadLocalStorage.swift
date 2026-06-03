#if canImport(pthread)
import pthread
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#endif

internal struct ThreadLocalStorage<Value>: ~Copyable {
    private let key: pthread_key_t

    public init() {
        var key: pthread_key_t = 0
        let errorCode: Int32 = pthread_key_create(&key, Self.makeBoxDestructor())

        precondition(
            errorCode == .zero,
            "Failed to create thread specific value key, error: \(errorCode)."
        )

        self.key = key
    }

    @available(*, noasync)
    public func get() -> Value? {
        guard let box: MutableBox = self.getBox() else {
            return nil
        }

        return box.value
    }

    @available(*, noasync)
    public func set(_ value: Value) {
        if let box: MutableBox = self.getBox() {
            box.value = value
        } else {
            self.setBox(MutableBox(value))
        }
    }

    @available(*, noasync)
    public func clear() {
        guard let pointer = pthread_getspecific(self.key) else {
            return
        }

        let errorCode: Int32 = pthread_setspecific(self.key, nil)
        precondition(
            errorCode == .zero,
            "Failed to remove thread specific value box, error: \(errorCode)."
        )

        Unmanaged<AnyObject>.fromOpaque(pointer).release()
    }

    @available(*, noasync)
    private func getBox() -> MutableBox? {
        guard let pointer: UnsafeMutableRawPointer = pthread_getspecific(self.key) else {
            return nil
        }

        let box: MutableBox = Unmanaged<MutableBox>
            .fromOpaque(pointer)
            .takeUnretainedValue()

        return box
    }

    @available(*, noasync)
    private func setBox(_ box: MutableBox) {
        assert(pthread_getspecific(self.key) == nil)

        let pointer: UnsafeMutableRawPointer = Unmanaged
            .passRetained(box)
            .toOpaque()

        let errorCode: Int32 = pthread_setspecific(self.key, pointer)
        precondition(
            errorCode == .zero,
            "Failed to set thread specific value box, error: \(errorCode)."
        )
    }

    deinit {
        let errorCode: Int32 = pthread_key_delete(self.key)
        precondition(
            errorCode == .zero,
            "Failed to delete thread specific value key, error: \(errorCode)."
        )
    }
}

// MARK: Mutable Box

extension ThreadLocalStorage {
    private final class MutableBox {
        public var value: Value

        public init(_ value: Value) {
            self.value = value
        }
    }
}

// MARK: Box Destructor

extension ThreadLocalStorage {
#if canImport(pthread)
    private static func makeBoxDestructor() -> @convention(c) (UnsafeMutableRawPointer) -> Void {
        { pointer in
            Unmanaged<AnyObject>.fromOpaque(pointer).release()
        }
    }
#elseif canImport(Glibc) || canImport(Musl)
    private static func makeBoxDestructor() -> @convention(c) (UnsafeMutableRawPointer?) -> Void {
        { pointer in
            guard let pointer else { return }

            Unmanaged<AnyObject>.fromOpaque(pointer).release()
        }
    }
#endif
}

// MARK: Sendable Conformance

extension ThreadLocalStorage: Sendable where Value: Sendable {
    // Empty.
}
