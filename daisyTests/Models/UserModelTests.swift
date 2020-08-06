//
//  UserModelTests.swift
//  daisyTests
//
//  Created by Galina on 06/08/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import XCTest
@testable import daisy

class UserModelTests: XCTestCase {

    var userTest: User!
    
    let expectedID = "1001"
    let expectedImageID = "1"
    let expectedName = "Test user"
    let expecteEmail = "example@email.com"
    let expectedBirthday = "1990-07-13"
    let expecteRole: uint = 1
    
    override func setUpWithError() throws {
        userTest = User(id: expectedID,
                        name: expectedName,
                        birthday: expectedBirthday,
                        email: expecteEmail,
                        role: expecteRole,
                        imageID: expectedImageID)
    }

    override func tearDownWithError() throws {
        userTest = nil
    }

    func testUserModel_CanCreateNewInstance() {
        XCTAssertNotNil(userTest)
        
        XCTAssertEqual(userTest.id, expectedID)
        XCTAssertEqual(userTest.imageID, expectedImageID)
        XCTAssertEqual(userTest.name, expectedName)
        XCTAssertEqual(userTest.email, expecteEmail)
        XCTAssertEqual(userTest.birthday, expectedBirthday)
        XCTAssertEqual(userTest.role, expecteRole)
        
        XCTAssertEqual(userTest.birthdayDate, expectedBirthday.toDate())
    }
}
