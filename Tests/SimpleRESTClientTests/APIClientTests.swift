//
//  APIClientTests.swift
//  
//
//  Created by Simon Lawrence on 22/01/2024.
//

import XCTest
@testable import SimpleRESTClient

struct DeleteResponse: Codable {
  var errors: [String]
}

struct DeleteEndpoint: Endpoint {
  func url(environment: SimpleRESTClient.Environment) async throws -> URL {
    return URL(string: "https://www.google.com")!
  }
}

final class APIClientTests: XCTestCase {

  var environment = ReqResEnvironment()
  lazy var bundle = Bundle(for: APIClientTests.self)
  lazy var transport = MockTransport(environment: environment)
  lazy var apiClient = APIClient(transport: transport)

  func testExample() async throws {

    let deleteResponse = MockResponse(statusCode: 200, filename: "DeleteResponse")!
    let deleteRequest = ExpectedRequest(url: "https://www.google.com", method: "DELETE", response: deleteResponse)
    transport.expect(deleteRequest)
    let result: DeleteResponse = try await apiClient.delete(endpoint: DeleteEndpoint())
    XCTAssert(!result.errors.isEmpty)
    XCTAssertEqual(result.errors.first, "No worries.")
    XCTAssertTrue(transport.allExpectedRequestsReceived)
  }
}
