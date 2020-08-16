//
//  DaisyServiceUserTests.swift
//  daisyTests
//
//  Created by Galina on 16/08/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import XCTest
@testable import daisy

class DaisyServiceUserTests: XCTestCase {
    var sut: DaisyService!
    var mockSession: MockURLSession!
    let bodyUser: [String: Any?] = [
        "name": "test",
        "email": "test@example.com",
        "password": "test",
        "birthday": Date().toDateString(),
        "image_id": nil]
    
    override func setUpWithError() throws {
        mockSession = MockURLSession()
        sut = DaisyService(session: mockSession)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockSession = nil
    }

    fileprivate func makeMockTask(endpoint: Endpoint, statusCode: Int, data: Data?, error: Error? = nil) -> MockURLSessionDataTask {
        let task = MockTaskMaker().makeTask(for: endpoint.path(),
                                            statusCode: statusCode,
                                            data: data,
                                            error: error)
        guard let fakeTask = task as? MockURLSessionDataTask else {
            XCTFail("Fail to create task")
            return MockURLSessionDataTask(data: nil, response: nil, error: nil)
        }
        mockSession.mockedTasks = fakeTask
        
        return fakeTask
    }
    
    fileprivate func assertIsSuccessTrueForResponse<T: Codable>(_ response: Response<T>) {
        XCTAssertNotNil(response)
        XCTAssert(response.isSuccess)
        XCTAssertNotNil(response.model)
    }
    
    fileprivate func assertIsSuccessFalseForResponse<T: Codable>(_ response: Response<T>) {
        XCTAssertNotNil(response)
        XCTAssertFalse(response.isSuccess)
        XCTAssertNotNil(response.errorMsg)
        XCTAssertNil(response.model)
    }
    
    func testDaisyService_getUser_resumeWasCalled() {
        // Arrange
        let fakeTask = makeMockTask(endpoint: Endpoint.user(id: "test"), statusCode: 200, data: "{}".data(using: .utf8))

        // Act
        sut.searchUser(userID: "test") { _ in }

        // Assert
        XCTAssert(fakeTask.isResumeCalled)
    }
    
    func testDaisyService_editUser_resumeWasCalled() {
        // Arrange
        let fakeTask = makeMockTask(endpoint: Endpoint.user(id: "test"), statusCode: 201, data: "{}".data(using: .utf8))

        // Act
        sut.editUser(userID: "test", body: ["name": name]) { _ in }

        // Assert
        XCTAssert(fakeTask.isResumeCalled)
    }

    func testDaisyService_getUser_WithResponseData_ReturnsSuccessful() {
        // Arrange
        let expect = expectation(description: "Should call daisy service search user get request, response expectation")
        let expectedData = """
        {
                    \"birthday\": \"2000-07-11\",
                    \"created_at\": \"2020-07-11T20:41:08.19944+02:00\",
                    \"email\": \"test@example.com\",
                    \"id\": \"test\",
                    \"image\": null,
                    \"image_id\": null,
                    \"name\": \"test\",
                    \"role\": 2,
                    \"updated_at\": \"2020-07-11T20:41:08.19944+02:00\"
        }
        """.data(using: .utf8)

        _ = makeMockTask(endpoint: Endpoint.user(id: "test"), statusCode: 200, data: expectedData)

        // Act
        sut.searchUser(userID: "test") { response in
            // Assert
            self.assertIsSuccessTrueForResponse(response)
            XCTAssertEqual(response.model?.id, "test")
            XCTAssertEqual(response.model?.email, "test@example.com")

            expect.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDaisyService_editUser_WithResponseData_ReturnsSuccessful() {
        // Arrange
        let expect = expectation(description: "Should call daisy service edit user patch request, response expectation")
        let expectedData = """
        {
                    \"birthday\": \"2000-07-11\",
                    \"created_at\": \"2020-07-11T20:41:08.19944+02:00\",
                    \"email\": \"test@example.com\",
                    \"id\": \"test\",
                    \"image\": null,
                    \"image_id\": null,
                    \"name\": \"test\",
                    \"role\": 2,
                    \"updated_at\": \"2020-07-11T20:41:08.19944+02:00\"
        }
        """.data(using: .utf8)

        _ = makeMockTask(endpoint: Endpoint.user(id: "test"), statusCode: 201, data: expectedData)

        // Act
        sut.editUser(userID: "test", body: bodyUser) { response in
            // Assert
            self.assertIsSuccessTrueForResponse(response)
            XCTAssertEqual(response.model?.id, "test")
            XCTAssertEqual(response.model?.name, "test")
            XCTAssertEqual(response.model?.email, "test@example.com")

            expect.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDaisyService_getUser_WithResponseData_ReturnsNotFound() {
        // Arrange
        let expect = expectation(description: "Should call daisy service search user get request with error and no result when task return status 404")
        _ = makeMockTask(endpoint: Endpoint.user(id: "test"), statusCode: 404, data: "{}".data(using: .utf8))

        // Act
        sut.searchUser(userID: "test") { response in
            // Assert
            self.assertIsSuccessFalseForResponse(response)
            XCTAssertEqual(response.errorMsg, "Resource not found")

            expect.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDaisyService_editUser_WithResponseData_ReturnsNotFound() {
        // Arrange
        let expect = expectation(description: "Should call daisy service edit user patch request with error and no result when task return status 404")

        _ = makeMockTask(endpoint: Endpoint.user(id: "test"), statusCode: 404, data: "{}".data(using: .utf8))

        // Act
        sut.editUser(userID: "test", body: bodyUser) { response in
            // Assert
            self.assertIsSuccessFalseForResponse(response)
            XCTAssertEqual(response.errorMsg, "Resource not found")

            expect.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDaisyService_getUser_WithResponseData_ReturnsUnauthorized() {
        // Arrange
        let expect = expectation(description: "Should call daisy service search user get request with unauthorized error and no result when task return status 401")
        _ = makeMockTask(endpoint: Endpoint.user(id: "test"), statusCode: 401, data: "{}".data(using: .utf8))

        // Act
        sut.searchUser(userID: "test") { response in
            // Assert
            self.assertIsSuccessFalseForResponse(response)
            XCTAssertEqual(response.errorMsg, "Unauthorized")

            expect.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDaisyService_editUser_WithResponseData_ReturnsUnauthorized() {
        // Arrange
        let expect = expectation(description: "Should call daisy service edit user patch request with unauthorized error and no result when task return status 401")
        _ = makeMockTask(endpoint: Endpoint.user(id: "test"), statusCode: 401, data: "{}".data(using: .utf8))

        // Act
        sut.editUser(userID: "test", body: bodyUser) { response in
            // Assert
            self.assertIsSuccessFalseForResponse(response)
            XCTAssertEqual(response.errorMsg, "Unauthorized")

            expect.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testAuthService_getUser_WithResponseData_ReturnsANetworkError() {
        // Arrange
        let expect = expectation(description: "Should call daisy service getRequest with network error")
        _ = makeMockTask(
            endpoint: Endpoint.user(id: "test"),
            statusCode: 0,
            data: "{}".data(using: .utf8),
            error: APIError.networkError(reason: "A network error"))

        // Act
        sut.searchUser(userID: "test") { response in
            // Assert
            self.assertIsSuccessFalseForResponse(response)

            expect.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testAuthService_editUser_WithResponseData_ReturnsANetworkError() {
        // Arrange
        let expect = expectation(description: "Should call daisy service patchRequest with network error")
        _ = makeMockTask(
            endpoint: Endpoint.user(id: "test"),
            statusCode: 0,
            data: "{}".data(using: .utf8),
            error: APIError.networkError(reason: "A network error"))

        // Act
        sut.editUser(userID: "test", body: bodyUser) { response in
            // Assert
            self.assertIsSuccessFalseForResponse(response)

            expect.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testAuthService_getUser_WithResponseData_ReturnsAUnknownError() {
        // Arrange
        let expect = expectation(description: "Should call daisy service getRequest with unknown error")

        _ = makeMockTask(endpoint: Endpoint.user(id: "test"), statusCode: 0, data: "{}".data(using: .utf8))

        // Act
        sut.searchUser(userID: "test") { response in
            // Assert
            self.assertIsSuccessFalseForResponse(response)
            XCTAssertEqual(response.errorMsg, "Unknown error")
            expect.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testAuthService_editUser_WithResponseData_ReturnsAUnknownError() {
        // Arrange
        let expect = expectation(description: "Should call daisy service patchRequest with unknown error")

        _ = makeMockTask(endpoint: Endpoint.user(id: "test"), statusCode: 0, data: "{}".data(using: .utf8))

        // Act
        sut.editUser(userID: "test", body: bodyUser) { response in
            // Assert
            self.assertIsSuccessFalseForResponse(response)
            XCTAssertEqual(response.errorMsg, "Unknown error")
            expect.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDaisyService_getUser_WithoutResponseData_ReturnsUnsuccessful() {
        // Arrange
        let expect = expectation(description: "Should call daisy service get request without data with error and no result")

        _ = makeMockTask(
            endpoint: Endpoint.user(id: "test"),
            statusCode: 0,
            data: nil)

        // Act
        sut.searchUser(userID: "test") { response in
            // Assert
            self.assertIsSuccessFalseForResponse(response)
            XCTAssertEqual(response.errorMsg, "Unable to unwrap data")

            expect.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDaisyService_editUser_WithoutResponseData_ReturnsUnsuccessful() {
        // Arrange
        let expect = expectation(description: "Should call daisy service patch request without data with error and no result")

        _ = makeMockTask(
            endpoint: Endpoint.user(id: "test"),
            statusCode: 0,
            data: nil)

        // Act
        sut.editUser(userID: "test", body: bodyUser) { response in
            // Assert
            self.assertIsSuccessFalseForResponse(response)
            XCTAssertEqual(response.errorMsg, "Unable to unwrap data")

            expect.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
}
