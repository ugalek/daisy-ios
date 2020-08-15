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
    
    fileprivate func assertIsSuccessTrue<T: Codable>(_ response: Response<T>) {
        XCTAssertNotNil(response)
        XCTAssert(response.isSuccess)
        XCTAssertNotNil(response.model)
    }
    
    fileprivate func assertIsSuccessFalse<T: Codable>(_ response: Response<T>) {
        XCTAssertNotNil(response)
        XCTAssertFalse(response.isSuccess)
        XCTAssertNotNil(response.errorMsg)
        XCTAssertNil(response.model)
    }
    
    fileprivate func makeMockRask(endpoint: Endpoint, statusCode: Int, data: Data?, error: Error? = nil) -> MockURLSessionDataTask {
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
    
    func testDaisyService_getRequest_resumeWasCalled() {
        // Arrange
        let fakeTask = makeMockRask(endpoint: Endpoint.user(id: "test"), statusCode: 200, data: "{}".data(using: .utf8))

        // Act
        sut.searchUser(userID: "test") { _ in }

        // Assert
        XCTAssert(fakeTask.isResumeCalled)
    }
    
    func testDaisyService_getRequest_WithResponseData_ReturnsSuccessful() {
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
        
        _ = makeMockRask(endpoint: Endpoint.user(id: "test"), statusCode: 200, data: expectedData)
        
        // Act
        sut.searchUser(userID: "test") { response in
            // Assert
            self.assertIsSuccessTrue(response)
            XCTAssertEqual(response.model?.id, "test")
            XCTAssertEqual(response.model?.email, "test@example.com")
            
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDaisyService_getRequest_WithResponseData_ReturnsNotFound() {
        // Arrange
        let expect = expectation(description: "Should call daisy service search user get request with error and no result when task return status 404")
        _ = makeMockRask(endpoint: Endpoint.user(id: "test"), statusCode: 404, data: "{}".data(using: .utf8))
        
        // Act
        sut.searchUser(userID: "test") { response in
            // Assert
            self.assertIsSuccessFalse(response)
            XCTAssertEqual(response.errorMsg, "Resource not found")
            
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDaisyService_getRequest_WithResponseData_ReturnsUnauthorized() {
        // Arrange
        let expect = expectation(description: "Should call daisy service search user get request with unauthorized error and no result when task return status 401")
        _ = makeMockRask(endpoint: Endpoint.user(id: "test"), statusCode: 401, data: "{}".data(using: .utf8))
        
        // Act
        sut.searchUser(userID: "test") { response in
            // Assert
            self.assertIsSuccessFalse(response)
            XCTAssertEqual(response.errorMsg, "Unauthorized")
            
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testAuthService_getRequest_WithResponseData_ReturnsANetworkError() {
        // Arrange
        let expect = expectation(description: "Should call daisy service getRequest with network error")
        _ = makeMockRask(
            endpoint: Endpoint.user(id: "test"),
            statusCode: 0,
            data: "{}".data(using: .utf8),
            error: APIError.networkError(reason: "A network error"))
        
        // Act
        sut.searchUser(userID: "test") { response in
            // Assert
            self.assertIsSuccessFalse(response)
                  
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testAuthService_getRequest_login_WithResponseData_ReturnsAUnknownError() {
        // Arrange
        let expect = expectation(description: "Should call daisy service getRequest with unknown error")

        _ = makeMockRask(endpoint: Endpoint.user(id: "test"), statusCode: 0, data: "{}".data(using: .utf8))

        // Act
        sut.searchUser(userID: "test") { response in
            // Assert
            self.assertIsSuccessFalse(response)
            XCTAssertEqual(response.errorMsg, "Unknown error")
            expect.fulfill()
        }
        
     
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDaisyService_getRequest_WithoutResponseData_ReturnsUnsuccessful() {
        // Arrange
        let expect = expectation(description: "Should call daisy service search get request without data with error and no result")
        
        _ = makeMockRask(
            endpoint: Endpoint.user(id: "test"),
            statusCode: 0,
            data: nil)
        
        // Act
        sut.searchUser(userID: "test") { response in
            // Assert
            self.assertIsSuccessFalse(response)
            XCTAssertEqual(response.errorMsg, "Unable to unwrap data")
            
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}
