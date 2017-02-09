//
//  MixedUpUITests.swift
//  MixedUpUITests
//
//  Created by Amy Roberson on 2/6/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import XCTest

class MixedUpUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        //let app = XCUIApplication()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    func testUnder21() {
        
        let app = XCUIApplication()
        let datePickersQuery = app.datePickers
        datePickersQuery.pickerWheels["2017"].swipeDown()
        datePickersQuery.pickerWheels["1989"].swipeLeft()
        app.buttons["Enter"].tap()
        app.staticTexts["Must be 21 or older to continue"].tap()
        XCTAssertEqual(app.buttons.count, 1)
        XCTAssert(app.pickerWheels.count == 1)
    }
    
}
