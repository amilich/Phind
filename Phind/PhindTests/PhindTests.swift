//
//  PhindTests.swift
//  PhindTests
//
//  Created by Andrew B. Milich on 1/26/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import XCTest
@testable import Phind

class PhindTests: XCTestCase {

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  // Maximum time difference in seconds to allow for conversion errors
  private static let MAX_TIME_EPS = 1.0
  /// Test conersion from UTC to local time
  func testLocalTimeConversion() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    let curTime = Date()
    let locTime = Util.UTCToLocal(date: curTime)
    let diff = locTime.timeIntervalSinceReferenceDate - curTime.timeIntervalSinceReferenceDate
    let correctDiff = TimeInterval(TimeZone.current.secondsFromGMT(for: curTime))
    XCTAssert(abs(correctDiff - diff) < PhindTests.MAX_TIME_EPS)
  }
  
  /// Test whether utility function for determining if date is today is correct; just tests current time. TODO: Add max/min bounds for day.
  func testIsDateToday() {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    formatter.timeZone = TimeZone.current
    let localTime = formatter.date(from: "2019-03-09T12:00:00")!
    XCTAssert(Util.IsDateToday(date: localTime))
  }

  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
        // Put the code you want to measure the time of here.
    }
  }

}
