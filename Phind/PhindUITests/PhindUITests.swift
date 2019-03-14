//
//  PhindUITests.swift
//  PhindUITests
//
//  Created by Andrew B. Milich on 1/26/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import XCTest

class PhindUITests: XCTestCase {
  var PhindApp: XCUIApplication!

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.

    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false

    super.setUp()
    PhindApp = XCUIApplication()
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testRefreshButton() {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    PhindApp.launch()
    PhindApp.buttons["refreshButton"].tap()
    // TODO finish the refresh button unit test
  }

}
