//
//  DaisyServiceListTests.swift
//  daisyTests
//
//  Created by Galina on 16/08/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import XCTest
@testable import daisy

class DaisyServiceListTests: XCTestCase {
    var sut: DaisyService!
    var mockSession: MockURLSession!
    
    let bodyList: [String: Any?] = [
        "title": "test",
        "surprise": false,
        "image_id": nil]

    let listID = "list_id"
    
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
    
    fileprivate func assertIsSuccessTrueForResponseArray<T: Codable>(_ response: ResponseArray<T>) {
        XCTAssertNotNil(response)
        XCTAssert(response.isSuccess)
        XCTAssertNotNil(response.model)
    }
    
    fileprivate func assertIsSuccessFalseForResponseArray<T: Codable>(_ response: ResponseArray<T>) {
        XCTAssertNotNil(response)
        XCTAssertFalse(response.isSuccess)
        XCTAssertNotNil(response.errorMsg)
        XCTAssertNil(response.model)
    }
    
    func testDaisyService_getLists_resumeWasCalled() {
        // Arrange
        let fakeTask = makeMockTask(endpoint: Endpoint.lists, statusCode: 200, data: "{}".data(using: .utf8))

        // Act
        sut.searchLists() { _ in }

        // Assert
        XCTAssert(fakeTask.isResumeCalled)
    }

    func testDaisyService_newList_resumeWasCalled() {
        // Arrange
        let fakeTask = makeMockTask(endpoint: Endpoint.lists, statusCode: 201, data: "{}".data(using: .utf8))

        // Act
        sut.newList(body: bodyList) { _ in }

        // Assert
        XCTAssert(fakeTask.isResumeCalled)
    }

    func testDaisyService_deleteRequest_resumeWasCalled() {
          // Arrange
          let fakeTask = makeMockTask(endpoint: Endpoint.lists, statusCode: 200, data: "{}".data(using: .utf8))

          // Act
          sut.deleteRequest(endpoint: Endpoint.lists) { _,_ in }

          // Assert
          XCTAssert(fakeTask.isResumeCalled)
      }
    
    func testDaisyService_getLists_WithResponseData_ReturnsSuccessful() {
        // Arrange
        let expect = expectation(description: "Should call daisy service search lists get request, response expectation")
        let expectedData = """
            [
                {
                                        \"created_at\": \"2020-08-02T11:31:39.442296+02:00\",
                                        \"id\": \"test_list\",
                                        \"image\": null,
                                        \"image_id\": null,
                                        \"surprise\": false,
                                        \"title\": \"List of items\",
                                        \"updated_at\": \"2020-08-02T11:31:39.442296+02:00\",
                                        \"user_id\": \"test_user\"
                }
            ]
        """.data(using: .utf8)

        _ = makeMockTask(endpoint: Endpoint.lists, statusCode: 200, data: expectedData)

        // Act
        sut.searchLists { response in
            // Assert
            self.assertIsSuccessTrueForResponseArray(response)

            XCTAssertEqual(response.model?[0].id, "test_list")
            XCTAssertEqual(response.model?[0].title, "List of items")
            XCTAssertEqual(response.model?[0].userID, "test_user")

            expect.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testDaisyService_editList_WithResponseData_ReturnsSuccessful() {
        // Arrange
        let expect = expectation(description: "Should call daisy service edit list patch request, response expectation")
        let expectedData = """
        {
                    \"id\": \"\(listID)\",
                    \"title\": \"test\",
                    \"image\": null,
                    \"image_id\": null,
                    \"surprise\": false,
                    \"created_at\": \"2020-07-11T20:41:08.19944+02:00\",
                    \"updated_at\": \"2020-07-11T20:41:08.19944+02:00\",
                    \"user_id\": \"test_user\"
        }
        """.data(using: .utf8)

        _ = makeMockTask(endpoint: Endpoint.list(id: "test"), statusCode: 201, data: expectedData)

        // Act
        sut.editList(listID: listID, body: bodyList) { response in
            // Assert
            self.assertIsSuccessTrueForResponse(response)
            XCTAssertEqual(response.model?.id, self.listID)
            XCTAssertEqual(response.model?.title, "test")
            XCTAssertEqual(response.model?.surprise, false)

            expect.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDaisyService_newList_WithResponseData_ReturnsSuccessful() {
        // Arrange
        let expect = expectation(description: "Should call daisy service new list post request, response expectation")
        let expectedData = """
        {
                    \"id\": \"\(listID)\",
                    \"title\": \"test\",
                    \"image\": null,
                    \"image_id\": null,
                    \"surprise\": false,
                    \"created_at\": \"2020-07-11T20:41:08.19944+02:00\",
                    \"updated_at\": \"2020-07-11T20:41:08.19944+02:00\",
                    \"user_id\": \"test_user\"
        }
        """.data(using: .utf8)

        _ = makeMockTask(endpoint: Endpoint.lists, statusCode: 201, data: expectedData)

        // Act
        sut.newList(body: bodyList) { response in
            // Assert
            self.assertIsSuccessTrueForResponse(response)
            XCTAssertEqual(response.model?.id, self.listID)
            XCTAssertEqual(response.model?.title, "test")
            XCTAssertEqual(response.model?.surprise, false)

            expect.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDaisyService_getLists_WithResponseData_ReturnsNotFound() {
        // Arrange
        let expect = expectation(description: "Should call daisy service search lists get request with error and no result when task return status 404")
        _ = makeMockTask(endpoint: Endpoint.lists, statusCode: 404, data: "{}".data(using: .utf8))

        // Act
        sut.searchLists { response in
            // Assert
            self.assertIsSuccessFalseForResponseArray(response)
            XCTAssertEqual(response.errorMsg, "Resource not found")

            expect.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDaisyService_deleteLists_WithResponseData_ReturnsNotFound() {
        // Arrange
        let expect = expectation(description: "Should call daisy service delete lists get request with error and no result when task return status 404")
        _ = makeMockTask(endpoint: Endpoint.lists, statusCode: 404, data: "{}".data(using: .utf8))

        // Act
        sut.deleteRequest(endpoint: Endpoint.lists) { response, err in
            // Assert
            XCTAssertFalse(response)
            XCTAssertNotNil(err)
            XCTAssertEqual(err, "Resource not found")

            expect.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDaisyService_newList_WithResponseData_ReturnsNotFound() {
        // Arrange
        let expect = expectation(description: "Should call daisy service new lists post request with error and no result when task return status 404")
        _ = makeMockTask(endpoint: Endpoint.lists, statusCode: 404, data: "{}".data(using: .utf8))

        // Act
        sut.newList(body: bodyList) { response in
            // Assert
            self.assertIsSuccessFalseForResponse(response)
            XCTAssertEqual(response.errorMsg, "Resource not found")

            expect.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDaisyService_getLists_WithResponseData_ReturnsUnauthorized() {
        // Arrange
        let expect = expectation(description: "Should call daisy service search lists get request with unauthorized error and no result when task return status 401")
        _ = makeMockTask(endpoint: Endpoint.lists, statusCode: 401, data: "{}".data(using: .utf8))

        // Act
        sut.searchLists { response in
            // Assert
            self.assertIsSuccessFalseForResponseArray(response)
            XCTAssertEqual(response.errorMsg, "Unauthorized")

            expect.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDaisyService_newList_WithResponseData_ReturnsUnauthorized() {
        // Arrange
        let expect = expectation(description: "Should call daisy service new list post request with unauthorized error and no result when task return status 401")
        _ = makeMockTask(endpoint: Endpoint.lists, statusCode: 401, data: "{}".data(using: .utf8))

        // Act
        sut.newList(body: bodyList) { response in
            // Assert
            self.assertIsSuccessFalseForResponse(response)
            XCTAssertEqual(response.errorMsg, "Unauthorized")

            expect.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testAuthService_getLists_WithResponseData_ReturnsANetworkError() {
        // Arrange
        let expect = expectation(description: "Should call daisy service getRequest with network error")
        _ = makeMockTask(
            endpoint: Endpoint.lists,
            statusCode: 0,
            data: "{}".data(using: .utf8),
            error: APIError.networkError(reason: "A network error"))

        // Act
        sut.searchLists { response in
            // Assert
            self.assertIsSuccessFalseForResponseArray(response)

            expect.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testAuthService_newList_WithResponseData_ReturnsANetworkError() {
        // Arrange
        let expect = expectation(description: "Should call daisy service postRequest with network error")
        _ = makeMockTask(
            endpoint: Endpoint.lists,
            statusCode: 0,
            data: "{}".data(using: .utf8),
            error: APIError.networkError(reason: "A network error"))

        // Act
        sut.newList(body: bodyList) { response in
            // Assert
            self.assertIsSuccessFalseForResponse(response)

            expect.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testAuthService_getLists_WithResponseData_ReturnsAUnknownError() {
        // Arrange
        let expect = expectation(description: "Should call daisy service getRequest with unknown error")

        _ = makeMockTask(endpoint: Endpoint.lists, statusCode: 0, data: "{}".data(using: .utf8))

        // Act
        sut.searchLists { response in
            // Assert
            self.assertIsSuccessFalseForResponseArray(response)
            XCTAssertEqual(response.errorMsg, "Unknown error")
            expect.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testAuthService_newList_WithResponseData_ReturnsAUnknownError() {
        // Arrange
        let expect = expectation(description: "Should call daisy service postRequest with unknown error")

        _ = makeMockTask(endpoint: Endpoint.lists, statusCode: 0, data: "{}".data(using: .utf8))

        // Act
        sut.newList(body: bodyList) { response in
            // Assert
            self.assertIsSuccessFalseForResponse(response)
            XCTAssertEqual(response.errorMsg, "Unknown error")
            expect.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDaisyService_getlists_WithoutResponseData_ReturnsUnsuccessful() {
        // Arrange
        let expect = expectation(description: "Should call daisy service get request without data with error and no result")

        _ = makeMockTask(
            endpoint: Endpoint.lists,
            statusCode: 0,
            data: nil)

        // Act
        sut.searchLists { response in
            // Assert
            self.assertIsSuccessFalseForResponseArray(response)
            XCTAssertEqual(response.errorMsg, "Unable to unwrap data")

            expect.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
}
