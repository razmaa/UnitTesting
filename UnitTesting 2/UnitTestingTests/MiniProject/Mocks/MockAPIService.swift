//
//  MockAPIService.swift
//  UnitTesting
//

@testable import UnitTesting

final class MockAPIService: APIServiceProtocol {
    var fetchUsersCallsCount = 0
    var lastFetchedUrl: String?
    var fetchUsersResult: Result<[User], APIError> = .success([])

    func fetchUsers(
        urlString: String,
        completion: @escaping (Result<[User], APIError>) -> Void
    ) {
        fetchUsersCallsCount += 1
        lastFetchedUrl = urlString
        completion(fetchUsersResult)
    }

    func fetchUsersAsync(urlString: String) async -> Result<[User], APIError> {
        fetchUsersCallsCount += 1
        lastFetchedUrl = urlString
        return fetchUsersResult
    }
}
