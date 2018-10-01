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

    func testUserDetails() {
        APIHelper.sharedInstance.getUserDetails(userLoginName: "chauhan130") { (result) -> (Void) in
            switch result {
            case .success(let user):
                XCTAssertTrue(user.location != "Ahmedabad")
            case .failure:
                XCTFail()
            }
        }
    }

    func testContributors() {
        let resultSetSize = 10
        APIHelper.sharedInstance.getContributors(from: "Alamofire/Alamofire", pageIndex: 0, numberOfRecordsPerPage: resultSetSize) { (result) -> (Void) in
            switch result {
            case .success(let users):
                XCTAssertFalse(users.count == resultSetSize)
            case .failure:
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
