#if canImport(pthread)
import pthread
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#endif

import class Foundation.Thread

internal func withFinalizingUniqueThread<Success, Failure: Error>(
    operation: @escaping @Sendable () throws(Failure) -> Success
) async throws(Failure) -> Success {
    let result: Result<Success, Failure> = await withCheckedContinuation { continuation in
        Thread.detachNewThread {
            let threadOperation = GenericThreadOperation(operation)

            let threadId: pthread_t = createPThread(threadOperation: threadOperation)

            let threadJoinErrorCode: Int32 = pthread_join(threadId, nil)
            precondition(threadJoinErrorCode == 0, "Failed to join p thread.")

            guard let operationResult: Result<Success, Failure> = threadOperation.result else {
                fatalError("No result available from thread operation.")
            }

            continuation.resume(returning: operationResult)
        }
    }

    return try result.get()
}

private func createPThread(threadOperation: ThreadOperation) -> pthread_t {
#if canImport(pthread)
    var threadId: pthread_t?
    let threadCreateErrorCode: Int32 = pthread_create(
        &threadId,
        nil,
        { pointer in
            Unmanaged<ThreadOperation>
                .fromOpaque(pointer)
                .takeRetainedValue()
                .execute()

            return nil
        },
        Unmanaged.passRetained(threadOperation).toOpaque()
    )

    guard let threadId, threadCreateErrorCode == 0 else {
        preconditionFailure("Failed to create p thread.")
    }
#elseif canImport(Glibc) || canImport(Musl)
    var threadId = pthread_t()
    let threadCreateErrorCode: Int32 = pthread_create(
        &threadId,
        nil,
        { pointer in
            guard let pointer else { return nil }

            Unmanaged<ThreadOperation>
                .fromOpaque(pointer)
                .takeRetainedValue()
                .execute()

            return nil
        },
        Unmanaged.passRetained(threadOperation).toOpaque()
    )

    guard threadCreateErrorCode == 0 else {
        preconditionFailure("Failed to create p thread.")
    }
#endif

    return threadId
}

private class ThreadOperation {
    public func execute() {
        // Empty.
    }
}

private final class GenericThreadOperation<Success, Failure: Error>: ThreadOperation {
    public private(set) var result: Result<Success, Failure>?

    private let operation: @Sendable () throws(Failure) -> Success

    public init(_ operation: @escaping @Sendable () throws(Failure) -> Success) {
        self.operation = operation
    }

    override public func execute() {
        self.result = Result(catching: operation)
    }
}
