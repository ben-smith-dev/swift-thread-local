internal func withMainThread<Success: Sendable, Failure: Error>(
    operation: @escaping @Sendable () throws(Failure) -> Success
) async throws(Failure) -> Success {
    let result: Result<Success, Failure> = await MainActor.run {
        Result(catching: operation)
    }

    return try result.get()
}
