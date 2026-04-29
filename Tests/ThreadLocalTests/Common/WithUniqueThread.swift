import Foundation

internal func withUniqueThread<Success, Failure: Error>(
    operation: @escaping @Sendable () throws(Failure) -> Success
) async throws(Failure) -> Success {
    let result: Result<Success, Failure> = await withCheckedContinuation { continuation in
        Thread.detachNewThread {
            continuation.resume(returning: Result(catching: operation))
        }
    }

    return try result.get()
}
