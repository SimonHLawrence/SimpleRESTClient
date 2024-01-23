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

    func process(endpoint: SimpleRESTClient.Endpoint, request: URLRequest) async throws -> URLRequest {

      switch endpoint {
      case ReqResEndpoint.login:
        return request
      default:
        return request.updating(headerFields: [HTTPHeader.authorization: RequestProcessorTests.bearer])
      }
    }
  }

  func testAddHeader() async throws {

    let requestProcessors: [RequestProcessor] = [MockOAuthRequestProcessor()]
    let environment = ReqResEnvironment()

    var endpoint = ReqResEndpoint.user(id: nil)
    var request = try await URLRequest(url: endpoint.url(environment: environment))

    var processedRequest = try await requestProcessors.process(endpoint: endpoint, request: request)
    XCTAssertNotNil(processedRequest.allHTTPHeaderFields)
    if let headers = processedRequest.allHTTPHeaderFields {
      XCTAssertEqual(headers[HTTPHeader.authorization], RequestProcessorTests.bearer)
    }

    endpoint = ReqResEndpoint.login
    request = try await URLRequest(url: endpoint.url(environment: environment))

    processedRequest = try await requestProcessors.process(endpoint: endpoint, request: request)
    XCTAssertNil(processedRequest.allHTTPHeaderFields)
  }
}
