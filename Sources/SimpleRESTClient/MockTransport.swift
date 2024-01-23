//
//  MockTransport.swift
//  SimpleRESTClient
//
//  Created by Simon Lawrence on 22/01/2024.
//

import Foundation

/// Mock API response for testing.
public struct MockResponse {
  public let statusCode: Int
  public let body: Data

  public init(statusCode: Int, body: Data) {
    self.statusCode = statusCode
    self.body = body
  }

  public init?(statusCode: Int, filename: String, sourceFolder: URL) {

    let mockURL = sourceFolder
      .appendingPathComponent(filename)
      .appendingPathExtension("json")

    guard
      let body = try? Data(contentsOf: mockURL) else {
      return nil
    }

    self.statusCode = statusCode
    self.body = body
  }
}

/// An expected API call and its associated response.
public struct ExpectedRequest {
  public let url: String
  public let method: String
  public let response: MockResponse

  public init(url: String, method: String, response: MockResponse) {
    self.url = url
    self.method = method
    self.response = response
  }
}

/// Mock implementation of ``Transport`` for unit testing.
open class MockTransport: Transport {

  open var environment: Environment
  open var requestProcessors: [RequestProcessor]
  open var expectedRequests: [ExpectedRequest] = []
  open var receivedRequests: [URLRequest] = []

  public init(environment: Environment, requestProcessors: [RequestProcessor] = []) {
    self.environment = environment
    self.requestProcessors = requestProcessors
  }

  /// Add an expected request and its associated response.
  /// - Parameter expectedRequest: the expected request.
  open func expect(_ expectedRequest: ExpectedRequest) {
    expectedRequests.append(expectedRequest)
  }

  /// True if all the expected requests have been received, false otherwise.
  open var allExpectedRequestsReceived: Bool {
    expectedRequests.isEmpty
  }

  open func execute(request: URLRequest, expectedStatusCodes: [Int]) async throws -> Data {

    receivedRequests.append(request)

    guard let urlString = request.url?.absoluteString else {
      throw URLError(.unsupportedURL)
    }

    if let index = expectedRequests.firstIndex(where: { expectedRequest in
      expectedRequest.url == urlString &&
      expectedRequest.method == request.httpMethod
    }) {
      let response = expectedRequests[index].response
      guard expectedStatusCodes.contains(response.statusCode) else {
        throw HTTPError(code: response.statusCode)
      }
      expectedRequests.remove(at: index)
      return response.body
    }
    throw HTTPError(code: 400)
  }

  func clear() {
    expectedRequests = []
    receivedRequests = []
  }
}
