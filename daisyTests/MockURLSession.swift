//
//  MockURLSession.swift
//  daisyTests
//
//  Created by Galina on 12/08/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import XCTest
@testable import daisy

//References:
//  --: https://www.hackingwithswift.com/articles/153/how-to-test-ios-networking-code-the-easy-way
class MockURLProtocol: URLProtocol {
    // this dictionary maps URLs to test data
    static var testURLs = [URL?: Data]()
    static var response: URLResponse?
    static var error: Error?
    
    // say we want to handle all types of request
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canInit(with task: URLSessionTask) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        // if we have a valid URL…
        if let url = request.url {
            // …and if we have test data for that URL…
            if let data = MockURLProtocol.testURLs[url] {
                // …load it immediately.
                self.client?.urlProtocol(self, didLoad: data)
            }
        }
        
        // …and we return our response if defined…
        if let response = MockURLProtocol.response {
            self.client?.urlProtocol(self,
                                     didReceive: response,
                                     cacheStoragePolicy: .notAllowed)
        }
        
        // …and we return our error if defined…
        if let error = MockURLProtocol.error {
            self.client?.urlProtocol(self, didFailWithError: error)
        }
        // mark that we've finished
        self.client?.urlProtocolDidFinishLoading(self)
    }
    
    // this method is required but doesn't need to do anything
    override func stopLoading() {
        
    }
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
