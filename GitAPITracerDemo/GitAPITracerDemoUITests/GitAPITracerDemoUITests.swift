//
//  GitAPITracerDemoUITests.swift
//  GitAPITracerDemoUITests
//
//  Created by Sunil Chauhan on 26/09/18.
//  Copyright © 2018 Sunil Chauhan. All rights reserved.
//

import XCTest

class GitAPITracerDemoUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        let window = XCUIApplication().windows["Window"]
        window.children(matching: .textField).element(boundBy: 2).click()
        window.buttons["Fetch Commits"].click()
        window.children(matching: .activityIndicator).element.click()
        window.click()
    }

}
