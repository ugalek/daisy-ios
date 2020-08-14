//
//  MockURLSession.swift
//  daisyTests
//
//  Created by Galina on 12/08/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import XCTest
@testable import daisy

class MockURLProtocol: URLProtocol {
    
    static var stubResponseData: Data?
    static var error: Error?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let signupError = MockURLProtocol.error {
            self.client?.urlProtocol(self, didFailWithError: signupError)
        } else {
            self.client?.urlProtocol(self, didLoad: MockURLProtocol.stubResponseData ?? Data())
        }
        self.client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() { }
}

class MockURLSession: URLSession {
    var mockedTasks: MockURLSessionDataTask!
    override init () { }

    override func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTask {
        
        mockedTasks.completionHandler = completionHandler
        
        return mockedTasks
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
    var completionHandler: DataTaskResult?
    public var isResumeCalled = false
    
    private var mockData: Data?
    private var mockError: Error?
    private var mockResponse: URLResponse?
    
    override var response: URLResponse? {
        return mockResponse
    }
    
    init(data: Data?, response: URLResponse?, error: Error?) {
        mockData = data
        mockError = error
        mockResponse = response
    }
    
    override func resume() {
        isResumeCalled = true
        completionHandler?(mockData, mockResponse, mockError)
    }
}

class MockResponse: HTTPURLResponse {
    private var mockStatusCode: Int = 404
    
    override var statusCode: Int {
        return mockStatusCode
    }
    
    init(url: URL, statusCode: Int) {
        mockStatusCode = statusCode
        super.init(url: url, mimeType: nil, expectedContentLength: 1, textEncodingName: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class MockTaskMaker {
    func makeTask(for urlPath: String, statusCode: Int, data: Data? = Data(), error: Error? = nil) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: URL(string: "http://localhost")!) { _, _, _ in }
        task.resume()
        
        guard let url = URL(string: urlPath) else {
            XCTFail("The URL generated is not valid")
            
            return task
        }
        
        let response = MockResponse(url: url, statusCode: statusCode)
        
        return MockURLSessionDataTask(data: data, response: response, error: error)
    }
}
