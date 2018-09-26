//
//  GitAPITracerTests.swift
//  GitAPITracerTests
//
//  Created by Sunil Chauhan on 29/06/18.
//  Copyright © 2018 Sunil Chauhan. All rights reserved.
//

import XCTest
@testable import GitAPITracer

class GitAPITracerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        APIHelper.sharedInstance.getUserDetails(userLoginName: "chauhan130") { (result) -> (Void) in
            switch result {
            case .success(let user):
                print("User found: \(user)")
                XCTAssertTrue(user.location != "Ahmedabad")
            case .failure(let error):
                print("Error: \(error)")
                XCTFail()
            }
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
