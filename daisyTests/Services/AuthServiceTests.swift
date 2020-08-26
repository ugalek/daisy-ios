//
//  AuthServiceTests.swift
//  daisyTests
//
//  Created by Galina on 09/08/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import XCTest
@testable import daisy

class AuthServiceTests: XCTestCase {
    var authClient: HttpAuth!
    var mockSession: MockURLSession!

    override func setUpWithError() throws {    
        mockSession = MockURLSession()
        authClient = HttpAuth(session: mockSession)
    }

    override func tearDownWithError() throws {
        authClient = nil
        mockSession = nil
    }
    
    func testAuthService_login_WithResponseData_ReturnsSuccessful() {
        let expect = expectation(description: "Should call auth service login userID response expectation")
        let expectedData = """
        {\"expired_at\":\"2020-08-14T19:49:46.643672+02:00\",
        \"token\":\"fake_token\",
        \"user_id\": \"01223344556677889900AABBCC\"}
        """.data(using: .utf8)
        
        let task = MockTaskMaker().makeTask(for: "http://localhost:3000/api/v1/auth",
                                                    statusCode: 200,
                                                    data: expectedData)
        guard let fakeTask = task as? MockURLSessionDataTask else {
            XCTFail()
            return
        }
        mockSession.mockedTasks = fakeTask
        
        authClient.login(email: "test", password: "test") { (userID, error) in
            guard userID != nil else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(userID, "01223344556677889900AABBCC")
            XCTAssertNil(error)
            
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testAuthService_login_resumeWasCalled() {
        let task = MockTaskMaker().makeTask(for: "http://localhost:3000/api/v1/auth",
                                                    statusCode: 200,
                                                    data: "{}".data(using: .utf8))
        guard let fakeTask = task as? MockURLSessionDataTask else {
            XCTFail()
            return
        }
        mockSession.mockedTasks = fakeTask

        authClient.login(email: "test", password: "test") { ( _, _) -> Void in }

        XCTAssert(fakeTask.isResumeCalled)
    }

    func testAuthService_login_WithResponseData_ReturnsUnauthorized() {
        let expect = expectation(description: "Should call auth service login with unauthorized error and no result when task return status 401")
        
        let failedTask = MockTaskMaker().makeTask(for: "http://localhost:3000/api/v1/auth",
                                                  statusCode: 401,
                                                  data: "{}".data(using: .utf8))
        
        mockSession.mockedTasks = failedTask as? MockURLSessionDataTask
        
        authClient.login(email: "test", password: "test") { (userID, error) in
            guard let error = error else {
                XCTFail()
                return
            }
            
            XCTAssertNotNil(error)
            XCTAssertNil(userID)
            
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testAuthService_login_WithResponseData_ReturnsNotFound() {
        let expect = expectation(description: "Should call auth service login with error and no result when task return status 404")
        
        let failedTask = MockTaskMaker().makeTask(for: "http://localhost:3000/api/v1/auth",
                                                  statusCode: 404,
                                                  data: "{}".data(using: .utf8))
        
        mockSession.mockedTasks = failedTask as? MockURLSessionDataTask
        
        authClient.login(email: "test", password: "test") { (userID, error) in
            guard let error = error else {
                XCTFail()
                return
            }
            
            XCTAssertNotNil(error)
            XCTAssertNil(userID)
            
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testAuthService_login_WithResponseData_ReturnsAUnknownError() {
        let expect = expectation(description: "Should call auth service login with unknown error")
        
        let failedTask = MockTaskMaker().makeTask(for: "http://localhost:3000/api/v1/auth",
                                                  statusCode: 0,
                                                  data: "{}".data(using: .utf8))
        
        mockSession.mockedTasks = failedTask as? MockURLSessionDataTask
        
        authClient.login(email: "test", password: "test") { (userID, error) in
            guard let error = error else {
                XCTFail()
                return
            }
            
            XCTAssertNotNil(error)
            XCTAssertNil(userID)
            
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testAuthService_login_WithResponseData_ReturnsANetworkError() {
        let expect = expectation(description: "Should call auth service login with network error")
        
        let failedTask = MockTaskMaker().makeTask(for: "http://localhost:3000/api/v1/auth",
                                                  statusCode: 0,
                                                  data: "{}".data(using: .utf8),
                                                  error: APIError.networkError(reason: "A network error"))
        
        mockSession.mockedTasks = failedTask as? MockURLSessionDataTask
        
        authClient.login(email: "test", password: "test") { (userID, error) in
            guard let error = error else {
                XCTFail()
                return
            }
            
            XCTAssertNotNil(error)
            XCTAssertNil(userID)
            
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}


