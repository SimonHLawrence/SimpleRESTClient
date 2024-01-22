//
//  NetworkTransport.swift
//  SimpleRESTClient
//
//  Created by Simon Lawrence on 20/01/2024.
//

import Foundation

public struct NetworkTransport: Transport {

  public let environment: Environment
  public let session: URLSession
  public let requestProcessors: [RequestProcessor]

  public init(environment: Environment, session: URLSession = .shared, requestProcessors: [RequestProcessor] = []) {
    self.environment = environment
    self.session = session
    self.requestProcessors = requestProcessors
  }

  public func execute(request: URLRequest, expectedStatusCodes: [Int]) async throws -> Data {

    let (data, response) = try await session.data(for: request)

    guard let httpURLResponse = response as? HTTPURLResponse else {
      throw URLError(.unsupportedURL)
    }

    let statusCode = httpURLResponse.statusCode

    guard expectedStatusCodes.contains(statusCode) else {
      throw HTTPError(code: statusCode)
    }

    return data
  }
}
