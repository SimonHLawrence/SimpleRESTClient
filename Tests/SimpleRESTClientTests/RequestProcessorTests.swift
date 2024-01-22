//
//  File.swift
//  
//
//  Created by Simon Lawrence on 22/01/2024.
//

import XCTest
@testable import SimpleRESTClient

final class RequestProcessorTests: XCTestCase {

  static let bearer = "Bearer 0329029082098321"
  struct MockOAuthRequestProcessor: RequestProcessor {
    func process(_ request: URLRequest) async throws -> URLRequest {
      request.updating(headerFields: [HTTPHeader.authorization: RequestProcessorTests.bearer])
    }
  }

  func testAddHeader() async throws {

    let requestProcessors: [RequestProcessor] = [MockOAuthRequestProcessor()]
    let request = URLRequest(url: URL(string: "https://www.google.com")!)
    let processedRequest = try await requestProcessors.process(request)
    XCTAssertNotNil(processedRequest.allHTTPHeaderFields)
    if let headers = processedRequest.allHTTPHeaderFields {
      XCTAssertEqual(headers[HTTPHeader.authorization], RequestProcessorTests.bearer)
    }
  }
}
