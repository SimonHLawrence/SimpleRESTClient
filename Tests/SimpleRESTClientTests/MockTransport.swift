//
//  MockTransport.swift
//  SimpleRESTClient
//
//  Created by Simon Lawrence on 22/01/2024.
//

import Foundation
@testable import SimpleRESTClient

public struct MockResponse {
  let statusCode: Int
  let body: Data

  init(statusCode: Int, body: Data) {
    self.statusCode = statusCode
    self.body = body
  }

  init?(statusCode: Int, filename: String) {

    let thisFile = URL(fileURLWithPath: #file)
    let thisDirectory = thisFile.deletingLastPathComponent()
    let mockURL = thisDirectory.appendingPathComponent("Data/\(filename)").appendingPathExtension("json")

    guard
      let body = try? Data(contentsOf: mockURL) else {
      return nil
    }

    self.statusCode = statusCode
    self.body = body
  }
}

public struct ExpectedRequest {
  let url: String
  let method: String
  let response: MockResponse
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

  open func expect(_ expectedRequest: ExpectedRequest) {
    expectedRequests.append(expectedRequest)
  }

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
