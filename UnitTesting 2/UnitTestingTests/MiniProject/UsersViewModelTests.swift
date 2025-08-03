//
//  UsersViewModelTests.swift
//  UnitTesting
//

@testable import UnitTesting
import XCTest

final class UsersViewModelTests: XCTestCase {
    var mockService: MockAPIService!

    override func setUp() {
        super.setUp()
        mockService = MockAPIService()
    }

    override func tearDown() {
        mockService = nil
        super.tearDown()
    }

    func test_viewModel_whenFetchUsers_callsApiService() {
        let sut = makeSut()
        sut.fetchUsers { }

        XCTAssertEqual(mockService.fetchUsersCallsCount, 1)
    }

    func test_viewModel_whenFetchUsers_passesCorrectUrlToApiService() {
        let sut = makeSut()
        sut.fetchUsers { }

        XCTAssertEqual(mockService.lastFetchedUrl, "https://jsonplaceholder.typicode.com/users")
    }

    func test_viewModel_fetchUsers_whenSuccess_updatesUsers() {
        mockService.fetchUsersResult = .success([
            User(id: 1, name: "name", username: "surname", email: "user@email.com")
        ])
        let sut = makeSut()

        let exp = expectation(description: "completion")
        sut.fetchUsers {
            XCTAssertEqual(sut.users.count, 1)
            XCTAssertEqual(sut.errorMessage, nil)
            XCTAssertEqual(sut.users.first?.name, "name")
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }

    func test_viewModel_fetchUsers_whenInvalidUrl_updatesErrorMessage() {
        mockService.fetchUsersResult = .failure(.invalidUrl)
        let sut = makeSut()

        let exp = expectation(description: "completion")
        sut.fetchUsers {
            XCTAssertEqual(sut.errorMessage, "Unexpected error")
            XCTAssertTrue(sut.users.isEmpty)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }

    func test_viewModel_fetchUsers_whenUnexectedFailure_updatesErrorMessage() {
        mockService.fetchUsersResult = .failure(.unexpected)
        let sut = makeSut()

        let exp = expectation(description: "completion")
        sut.fetchUsers {
            XCTAssertEqual(sut.errorMessage, "Unexpected error")
            XCTAssertTrue(sut.users.isEmpty)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }

    func test_viewModel_fetchUsers_whenParsingFailure_updatesErrorMessage() {
        mockService.fetchUsersResult = .failure(.parsingError)
        let sut = makeSut()

        let exp = expectation(description: "completion")
        sut.fetchUsers {
            XCTAssertEqual(sut.errorMessage, "Error parsing JSON")
            XCTAssertTrue(sut.users.isEmpty)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }

    func test_viewModel_clearUsers() {
        mockService.fetchUsersResult = .success([
            User(id: 1, name: "Test", username: "test", email: "test@email.com")
        ])
        let sut = makeSut()

        let exp = expectation(description: "fetch and clear")
        sut.fetchUsers {
            XCTAssertFalse(sut.users.isEmpty)
            sut.clearUsers()
            XCTAssertTrue(sut.users.isEmpty)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }

    private func makeSut() -> UsersViewModel {
        UsersViewModel(apiService: mockService)
    }
}

