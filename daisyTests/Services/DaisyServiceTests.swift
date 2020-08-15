//
//  DaisyServiceTests.swift
//  daisyTests
//
//  Created by Galina on 15/08/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import XCTest
@testable import daisy

class DaisyServiceTests: XCTestCase {
    var sut: DaisyService!
    var mockSession: MockURLSession!

    override func setUpWithError() throws {
        mockSession = MockURLSession()
        sut = DaisyService(session: mockSession)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockSession = nil
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
    
    func testDaisyService_Endpoint_ReturnsPathString() {
        XCTAssertEqual(Endpoint.images.path(), "images/")
        XCTAssertEqual(Endpoint.image(imageID: "1").path(), "images/1")
        XCTAssertEqual(Endpoint.user(id: "1").path(), "users/1")
        XCTAssertEqual(Endpoint.lists.path(), "lists/")
        XCTAssertEqual(Endpoint.list(id: "1").path(), "lists/1")
        XCTAssertEqual(Endpoint.items(listID: "1").path(), "lists/1/items")
        XCTAssertEqual(Endpoint.item(listID: "1", id: "2").path(), "lists/1/items/2")
    }
    
    func testDaisyService_getUser_resumeWasCalled() {
        // Arrange
        let fakeTask = makeMockTask(endpoint: Endpoint.user(id: "test"), statusCode: 200, data: "{}".data(using: .utf8))

        // Act
        sut.searchUser(userID: "test") { _ in }

        // Assert
        XCTAssert(fakeTask.isResumeCalled)
    }
    
    func testDaisyService_getLists_resumeWasCalled() {
        // Arrange
        let fakeTask = makeMockTask(endpoint: Endpoint.lists, statusCode: 200, data: "{}".data(using: .utf8))

        // Act
        sut.searchLists() { _ in }

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
    
    func testDaisyService_getUser_WithoutResponseData_ReturnsUnsuccessful() {
        // Arrange
        let expect = expectation(description: "Should call daisy service search get request without data with error and no result")
        
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
    
    func testDaisyService_getlists_WithoutResponseData_ReturnsUnsuccessful() {
        // Arrange
        let expect = expectation(description: "Should call daisy service search get request without data with error and no result")
        
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
