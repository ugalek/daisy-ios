//
//  ItemModelTests.swift
//  daisyTests
//
//  Created by Galina on 06/08/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import XCTest
import SwiftUI
@testable import daisy

class ItemModelTests: XCTestCase {

    var itemTest: Item!
    
    let expectedID = "1001"
    let expectedListID = "1"
    let expectedTitle = "Test item"
    let expectedImageID = "1"
    let expectedUrl = "http://test.com"
    let expectedPrice = 10.1
    let expectedDescription = "Description of test item"
    let expectedStatus: uint = 1
    
    override func setUp() {
        super.setUp()
        itemTest = Item(id: expectedID,
                         listID: expectedListID,
                         title: expectedTitle,
                         imageID: expectedImageID,
                         url: expectedUrl,
                         price: expectedPrice,
                         description: expectedDescription,
                         status: expectedStatus)
    }
    
    override func tearDown() {
        super.tearDown()
        itemTest = nil
    }

    func testItemModel_CanCreateNewInstance() {
        XCTAssertNotNil(itemTest)
        
        XCTAssertEqual(itemTest.id, expectedID)
        XCTAssertEqual(itemTest.listID, expectedListID)
        XCTAssertEqual(itemTest.title, expectedTitle)
        XCTAssertEqual(itemTest.imageID, expectedImageID)
        XCTAssertEqual(itemTest.url, expectedUrl)
        XCTAssertEqual(itemTest.price, expectedPrice)
        XCTAssertEqual(itemTest.description, expectedDescription)
        XCTAssertEqual(itemTest.status, expectedStatus)
    }
    
    func testItemModel_shouldGetRawStatus() {
        var rawStatus = Item.getRawStatus(status: itemTest.status)
        XCTAssertEqual(rawStatus, "")
        
        // Reserved
        rawStatus = Item.getRawStatus(status: 2)
        XCTAssertEqual(rawStatus, "Reserved")
        
        // Taken
        rawStatus = Item.getRawStatus(status: 3)
        XCTAssertEqual(rawStatus, "Taken")
    }
    
    func testItemModel_shouldGetIconColor() {
        var iconColor = Item.getIconColor(status: itemTest.status)
        XCTAssertNil(iconColor)
        
        // Reserved
        iconColor = Item.getIconColor(status: 2)
        XCTAssertEqual(iconColor, Color.dSecondaryButton)

        // Taken
        iconColor = Item.getIconColor(status: 3)
        XCTAssertEqual(iconColor, Color.gray)
    }
    
    func testItemModel_shouldGetBandColor() {
        var bandColor = Item.getBandColor(status: itemTest.status)
        XCTAssertNil(bandColor)
        
        // Reserved
        bandColor = Item.getBandColor(status: 2)
        XCTAssertEqual(bandColor, Color("Reserved"))

        // Taken
        bandColor = Item.getBandColor(status: 3)
        XCTAssertEqual(bandColor, Color("Taken"))
    }
    
    func testItemModel_shouldGetPriceString() {
        let priceString = Item.getPriceString(price: itemTest.price)
        let expectedPriceString = String(format: "%.2f", itemTest.price!)
        XCTAssertEqual(priceString, expectedPriceString)
        
        let priceNilString = Item.getPriceString(price: nil)
        XCTAssertEqual(priceNilString, "0.00")
    }
}
