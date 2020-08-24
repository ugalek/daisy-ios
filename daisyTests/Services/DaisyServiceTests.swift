//
//  DaisyServiceTests.swift
//  daisyTests
//
//  Created by Galina on 15/08/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import XCTest
import SwiftUI
import Combine

@testable import daisy

class DaisyServiceTests: XCTestCase {
    var sut: DaisyService!
    var mockSession: MockURLSession!
    
    let bodyUser: [String: Any?] = [
        "name": "test",
        "email": "test@example.com",
        "password": "test",
        "birthday": Date().toDateString(),
        "image_id": nil]
    
    let bodyList: [String: Any?] = [
        "title": "test",
        "surprise": false,
        "image_id": nil]
    
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
    
    fileprivate func assertIsSuccessFalseForResponseArray<T: Codable>(_ response: ResponseArray<T>) {
        XCTAssertNotNil(response)
        XCTAssertFalse(response.isSuccess)
        XCTAssertNotNil(response.errorMsg)
        XCTAssertNil(response.model)
    }
    
    func testDaisyService_Endpoint_ReturnsPathString() {
        XCTAssertEqual(Endpoint.images.path(), "images/")
        XCTAssertEqual(Endpoint.image(imageID: "1").path(), "images/1")
        XCTAssertEqual(Endpoint.user(id: "1").path(), "users/1")
        XCTAssertEqual(Endpoint.lists.path(), "lists/")
        XCTAssertEqual(Endpoint.list(id: listID).path(), "lists/\(listID)")
        XCTAssertEqual(Endpoint.items(listID: listID).path(), "lists/\(listID)/items")
        XCTAssertEqual(Endpoint.item(listID: listID, id: itemID).path(), "lists/\(listID)/items/\(itemID)")
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

        _ = makeMockTask(endpoint: Endpoint.item(listID: listID, id: "test_item"), statusCode: 200, data: expectedData)

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

    
    // USER
    
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
        let fakeTask = makeMockTask(endpoint: Endpoint.user(id: "test"), statusCode: 200, data: "{}".data(using: .utf8))

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

        _ = makeMockTask(endpoint: Endpoint.user(id: "test"), statusCode: 200, data: expectedData)

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
    
    // LIST
    
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
        let fakeTask = makeMockTask(endpoint: Endpoint.lists, statusCode: 200, data: "{}".data(using: .utf8))

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

        _ = makeMockTask(endpoint: Endpoint.list(id: "test"), statusCode: 200, data: expectedData)

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
