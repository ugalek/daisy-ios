//
//  DaisyServiceItemTests.swift
//  daisyTests
//
//  Created by Galina on 16/08/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import XCTest
@testable import daisy

class DaisyServiceItemTests: XCTestCase {
    var sut: DaisyService!
    var mockSession: MockURLSession!
    
    let bodyItem: [String: Any?] = [
        "title": "test",
        "description": "description",
        "image_id": nil]
    
    let listID = "list_id"
    let itemID = "item_id"
    
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
    
    func testDaisyService_newItem_resumeWasCalled() {
        // Arrange
        let fakeTask = makeMockTask(endpoint: Endpoint.lists, statusCode: 201, data: "{}".data(using: .utf8))

        // Act
        sut.newItem(listID: listID, body: bodyItem) { _ in }

        // Assert
        XCTAssert(fakeTask.isResumeCalled)
    }

    func testDaisyService_editItem_WithResponseData_ReturnsSuccessful() {
        // Arrange
        let expect = expectation(description: "Should call daisy service edit item patch request, response expectation")
        let expectedData = """
                        {
                            \"created_at\": \"2020-08-02T11:31:58.227224+02:00\",
                            \"description\": \"Description\",
                            \"id\": \"\(itemID)\",
                            \"image\": {
                                \"content_type\": \"image/png\",
                                \"created_at\": \"2020-08-02T11:31:58.217421+02:00\",
                                \"extension\": \".png\",
                                \"id\": \"test_image\",
                                \"path\": \"upload/test_user/test_image.png\",
                                \"size\": 496540,
                                \"url\": \"http://localhost:3000/media/upload/test_user/test_image.png\",
                                \"user_id\": \"test_user\"
                            },
                            \"image_id\": \"test_image\",
                            \"list_id\": \"\(listID)\",
                            \"price\": 25,
                            \"status\": 1,
                            \"title\": \"item\",
                            \"updated_at\": \"2020-08-02T11:31:58.227224+02:00\",
                            \"url\": \"http://test.com\"
                        }
        """.data(using: .utf8)
        
        let bodyItem: [String: Any?] = [
            "title": "item",
            "image_id": nil]

        _ = makeMockTask(endpoint: Endpoint.item(listID: listID, id: "test_item"), statusCode: 201, data: expectedData)

        // Act
        sut.editItem(listID: listID, itemID: itemID, body: bodyItem) { response in
            // Assert
            self.assertIsSuccessTrueForResponse(response)
            XCTAssertEqual(response.model?.id, self.itemID)
            XCTAssertEqual(response.model?.title, "item")

            expect.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDaisyService_getItems_WithResponseData_ReturnsSuccessful() {
        // Arrange
        let expect = expectation(description: "Should call daisy service search items get request, response expectation")
        let expectedData = """
            [
                {
                    \"created_at\": \"2020-08-02T11:31:58.227224+02:00\",
                    \"description\": \"Description\",
                    \"id\": \"test_item\",
                    \"image\": {
                        \"content_type\": \"image/png\",
                        \"created_at\": \"2020-08-02T11:31:58.217421+02:00\",
                        \"extension\": \".png\",
                        \"id\": \"test_image\",
                        \"path\": \"upload/test_user/test_image.png\",
                        \"size\": 496540,
                        \"url\": \"http://localhost:3000/media/upload/test_user/test_image.png\",
                        \"user_id\": \"test_user\"
                    },
                    \"image_id\": \"test_image\",
                    \"list_id\": \"\(listID)\",
                    \"price\": 25,
                    \"status\": 1,
                    \"title\": \"item\",
                    \"updated_at\": \"2020-08-02T11:31:58.227224+02:00\",
                    \"url\": \"http://test.com\"
                }
            ]
        """.data(using: .utf8)

        _ = makeMockTask(endpoint: Endpoint.items(listID: listID), statusCode: 200, data: expectedData)

        // Act
        sut.searchItems(listID: listID) { response in
            // Assert
            self.assertIsSuccessTrueForResponseArray(response)

            XCTAssertEqual(response.model?[0].id, "test_item")
            XCTAssertEqual(response.model?[0].description, "Description")
            XCTAssertEqual(response.model?[0].listID, self.listID)
            XCTAssertEqual(response.model?[0].image?.id, response.model?[0].imageID)

            expect.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDaisyService_newItem_WithResponseData_ReturnsNotFound() {
        // Arrange
        let expect = expectation(description: "Should call daisy service new item post request with error and no result when task return status 404")
        _ = makeMockTask(endpoint: Endpoint.items(listID: listID), statusCode: 404, data: "{}".data(using: .utf8))

        // Act
        sut.newItem(listID: listID, body: bodyItem) { response in
            // Assert
            self.assertIsSuccessFalseForResponse(response)
            XCTAssertEqual(response.errorMsg, "Resource not found")

            expect.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDaisyService_newItem_WithResponseData_ReturnsUnauthorized() {
        // Arrange
        let expect = expectation(description: "Should call daisy service new item post request with unauthorized error and no result when task return status 401")
        _ = makeMockTask(endpoint: Endpoint.items(listID: listID), statusCode: 401, data: "{}".data(using: .utf8))

        // Act
        sut.newItem(listID: listID, body: bodyItem) { response in
            // Assert
            self.assertIsSuccessFalseForResponse(response)
            XCTAssertEqual(response.errorMsg, "Unauthorized")

            expect.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testAuthService_newItem_WithResponseData_ReturnsANetworkError() {
        // Arrange
        let expect = expectation(description: "Should call daisy service postRequest with network error")
        _ = makeMockTask(
            endpoint: Endpoint.items(listID: listID),
            statusCode: 0,
            data: "{}".data(using: .utf8),
            error: APIError.networkError(reason: "A network error"))

        // Act
        sut.newItem(listID: listID, body: bodyItem) { response in
            // Assert
            self.assertIsSuccessFalseForResponse(response)

            expect.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testAuthService_newitem_WithResponseData_ReturnsAUnknownError() {
        // Arrange
        let expect = expectation(description: "Should call daisy service postRequest with unknown error")

        _ = makeMockTask(endpoint: Endpoint.items(listID: listID), statusCode: 0, data: "{}".data(using: .utf8))

        // Act
        sut.newItem(listID: listID, body: bodyItem) { response in
            // Assert
            self.assertIsSuccessFalseForResponse(response)
            XCTAssertEqual(response.errorMsg, "Unknown error")
            expect.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
    
}
