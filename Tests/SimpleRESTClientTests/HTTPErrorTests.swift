//
//  HTTPErrorTests.swift
//  
//
//  Created by Simon Lawrence on 22/01/2024.
//

import XCTest
@testable import SimpleRESTClient

final class HTTPErrorTests: XCTestCase {

  func testExample() async throws {
    var error = HTTPError(code: 400)
    XCTAssertEqual(error.localizedDescription, "bad request")
    error = HTTPError(code: 404)
    XCTAssertEqual(error.localizedDescription, "not found")
  }
}
