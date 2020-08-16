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
    var customPublisher: APISessionDataPublisher!

    let listID = "list_id"
    let itemID = "item_id"
    
    override func setUpWithError() throws {
        // now set up a configuration to use our mock
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        
        // and create the URLSession from that
        let session = URLSession(configuration: config)
        customPublisher = APISessionDataPublisher(session: session)
    }

    override func tearDownWithError() throws {
        //Restore the default publisher
        DaisyService.publisher = APISessionDataPublisher()
        
        MockURLProtocol.response = nil
        MockURLProtocol.error = nil
        MockURLProtocol.testURLs = [URL?: Data]()
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
    
    func testDaisyService_uploadImageDTP() {
        // Arrange
        let future = DaisyService.uploadImageDTP(image: UIImage(systemName: "circle.fill")!)
        let request = future.request
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertNotNil(request.httpBody)
    }
    
    func evalValidResponseTest<T:Publisher>(publisher: T?) -> (expectations:[XCTestExpectation], cancellable: AnyCancellable?) {
        XCTAssertNotNil(publisher)
        
        let expectationFinished = expectation(description: "finished")
        let expectationReceive = expectation(description: "receiveValue")
        let expectationFailure = expectation(description: "failure")
        expectationFailure.isInverted = true
        
        let cancellable = publisher?.sink (receiveCompletion: { (completion) in
            switch completion {
            case .failure(let error):
                print("--TEST ERROR--")
                print(error.localizedDescription)
                print("------")
                expectationFailure.fulfill()
            case .finished:
                expectationFinished.fulfill()
            }
        }, receiveValue: { response in
            XCTAssertNotNil(response)
            print(response)
            expectationReceive.fulfill()
        })
        return (expectations: [expectationFinished, expectationReceive, expectationFailure],
                cancellable: cancellable)
    }
    
    func testDaisyService_UploadImage() {
        //Setup fixture
        let image = UIImage(systemName: "circle.fill")
        let imagesURL = URL(string: "/images/")
        let expectedData = """
        {
            \"id\": \"image_id\",
            \"image\": null,
            \"created_at\": \"2020-07-11T20:41:08.19944+02:00\",
            \"updated_at\": \"2020-07-11T20:41:08.19944+02:00\",
            \"user_id\": \"test_user\"
        }
        """.data(using: .utf8)
        
        MockURLProtocol.testURLs = [imagesURL: expectedData!]
        
        DaisyService.publisher = customPublisher
        MockURLProtocol.response = HTTPURLResponse(url: URL(string: "http://localhost")!,
                                                   statusCode: 200,
                                                   httpVersion: nil,
                                                   headerFields: nil)
        let publisher = DaisyService.uploadImageDTP(image: image!)
        
        let validTest = evalValidResponseTest(publisher: publisher)
        wait(for: validTest.expectations, timeout: 5)
        validTest.cancellable?.cancel()
    }
}
