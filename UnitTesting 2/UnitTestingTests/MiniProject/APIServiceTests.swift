//
//  APIServiceTests.swift
//  UnitTesting
//

import XCTest
@testable import UnitTesting

final class APIServiceTests: XCTestCase {
    var mockURLSession: MockURLSession!

    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSession()
    }

    override func tearDown() {
        mockURLSession = nil
        super.tearDown()
    }

    // MARK: Fetch Users

    func test_apiService_fetchUsers_whenInvalidUrl_completesWithError() {
        let sut = makeSut()
        let exp = expectation(description: "completion")

        sut.fetchUsers(urlString: "not a url") { result in
            if case let .failure(error) = result {
                XCTAssertEqual(error, .invalidUrl)
            } else {
                XCTFail("Expected failure(.invalidUrl), got \(result)")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }

    func test_apiService_fetchUsers_whenValidSuccessfulResponse_completesWithSuccess() {
        let response = """
        [
            { "id": 1, "name": "John Doe", "username": "johndoe", "email": "johndoe@gmail.com" },
            { "id": 2, "name": "Jane Doe", "username": "johndoe", "email": "johndoe@gmail.com" }
        ]
        """.data(using: .utf8)
        mockURLSession.mockData = response

        let sut = makeSut()
        let exp = expectation(description: "completion")

        sut.fetchUsers(urlString: "https://example.com") { result in
            if case let .success(users) = result {
                XCTAssertEqual(users.count, 2)
                XCTAssertEqual(users[0].name, "John Doe")
                XCTAssertEqual(users[1].name, "Jane Doe")
            } else {
                XCTFail("Expected success, got \(result)")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }

    func test_apiService_fetchUsers_whenInvalidSuccessfulResponse_completesWithFailure() {
        mockURLSession.mockData = Data("not-json".utf8)

        let sut = makeSut()
        let exp = expectation(description: "completion")

        sut.fetchUsers(urlString: "https://example.com") { result in
            if case let .failure(error) = result {
                XCTAssertEqual(error, .parsingError)
            } else {
                XCTFail("Expected failure(.parsingError), got \(result)")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }

    func test_apiService_fetchUsers_whenError_completesWithFailure() {
        mockURLSession.mockError = URLError(.timedOut)

        let sut = makeSut()
        let exp = expectation(description: "completion")

        sut.fetchUsers(urlString: "https://example.com") { result in
            if case let .failure(error) = result {
                XCTAssertEqual(error, .unexpected)
            } else {
                XCTFail("Expected failure(.unexpected), got \(result)")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }

    // MARK: Fetch Users Async

    func test_apiService_fetchUsersAsync_whenInvalidUrl_completesWithError() async {
        let sut = makeSut()
        let result = await sut.fetchUsersAsync(urlString: "🤯")

        if case let .failure(error) = result {
            XCTAssertEqual(error, .invalidUrl)
        } else {
            XCTFail("Expected failure(.invalidUrl), got \(result)")
        }
    }

    func test_apiService_fetchUsersAsync_whenValidSuccessfulResponse_completesWithSuccess() async {
        mockURLSession.mockData = """
        [
            { "id": 1, "name": "John Doe", "username": "johndoe", "email": "johndoe@gmail.com" },
            { "id": 2, "name": "Jane Doe", "username": "johndoe", "email": "johndoe@gmail.com" }
        ]
        """.data(using: .utf8)

        let sut = makeSut()
        let result = await sut.fetchUsersAsync(urlString: "https://example.com")

        switch result {
        case .success(let users):
            XCTAssertEqual(users.count, 2)
            XCTAssertEqual(users[0].name, "John Doe")
            XCTAssertEqual(users[1].name, "Jane Doe")
        default:
            XCTFail("Expected success, got \(result)")
        }
    }

    func test_apiService_fetchUsersAsync_whenInvalidJson_completesWithFailure() async {
        mockURLSession.mockData = Data("invalid json".utf8)

        let sut = makeSut()
        let result = await sut.fetchUsersAsync(urlString: "https://example.com")

        if case let .failure(error) = result {
            XCTAssertEqual(error, .parsingError)
        } else {
            XCTFail("Expected failure(.parsingError), got \(result)")
        }
    }

    func test_apiService_fetchUsersAsync_whenError_completesWithFailure() async {
        mockURLSession.mockError = URLError(.notConnectedToInternet)

        let sut = makeSut()
        let result = await sut.fetchUsersAsync(urlString: "https://example.com")

        if case let .failure(error) = result {
            XCTAssertEqual(error, .unexpected)
        } else {
            XCTFail("Expected failure(.unexpected), got \(result)")
        }
    }

    private func makeSut() -> APIService {
        APIService(urlSession: mockURLSession)
    }
}

