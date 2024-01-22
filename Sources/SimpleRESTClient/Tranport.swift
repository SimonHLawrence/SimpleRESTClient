//
//  Transport.swift
//  SimpleRESTClient
//
//  Created by Simon Lawrence on 20/01/2024.
//

import Foundation

/// An environment in which API calls can be made.
public protocol Environment {
  /// The host name for the environment.
  var hostname: String { get }
  /// The port number for the environment.
  var portNumber: Int? { get }
}

/// An endpoint that can be resolved to a URL for an API call.
public protocol Endpoint {
  /// Resolve a URL for the endpoint in the supplied environment.
  /// - Parameter environment: the environment in which the call will be executed.
  /// - Returns: the fully qualified URL for the API call.
  func url(environment: Environment) async throws -> URL
}

/// Represents an instance that can process a ``URLRequest``, for instance to
/// add headers for authentication.
public protocol RequestProcessor {
  /// Process the supplied request, adding additional information.
  /// - Parameter request: the initial request.
  /// - Returns: the processed request.
  func process(_ request: URLRequest) async throws -> URLRequest
}

extension [RequestProcessor]: RequestProcessor {
  /// Apply the specified ``RequestProcessor`` instances in order to generate a processed request.
  /// - Parameter request: the intial request.
  /// - Returns: the processed request.
  public func process(_ request: URLRequest) async throws -> URLRequest {
    var result = request
    for element in self {
      result = try await element.process(result)
    }
    return result
  }
}

/// A type providing authenticated REST operations.
public protocol Transport {
  /// The environment in which API calls will be made.
  var environment: Environment { get }
  /// A list of request processors that will be applied to each API call request.
  var requestProcessors: [RequestProcessor] { get }
  /// Create a URL request for the specified endpoint, HTTP method and request body (if supplied).
  /// - Parameters:
  ///   - endpoint: the endpoint for the API call.
  ///   - method: the HTTP method, e.g. "GET"
  ///   - data: the reqeuest body (if specified).
  /// - Returns: The URL request.
  func urlRequest(endpoint: Endpoint, method: String, data: Data?) async throws -> URLRequest
  /// Execute the supplied URL request.
  /// - Parameters:
  ///   - request: the request to execute.
  ///   - expectedStatusCodes: the acceptable HTTP status codes for the response.
  /// - Returns: The data retrieved from the response.
  func execute(request: URLRequest, expectedStatusCodes: [Int]) async throws -> Data
  /// GET the response from the specified endpoint.
  /// - Parameter endpoint: the endpoint for the API call.
  /// - Returns: The data retrieved from the response.
  func get(endpoint: Endpoint) async throws -> Data
  /// PUT the supplied data to the specified endpoint.
  /// - Parameters:
  ///   - endpoint: the endpoint for the API call.
  ///   - data: the data to put.
  /// - Returns: The data retrieved from the response.
  func put(endpoint: Endpoint, data: Data) async throws -> Data
  /// POST the supplied data to the specified endpoint.
  /// - Parameters:
  ///   - endpoint: the endpoint for the API call.
  ///   - data: the data to post.
  /// - Returns: The data retrieved from the response.
  func post(endpoint: Endpoint, data: Data) async throws -> Data
  /// DELETE the specified endpoint.
  /// - Parameter endpoint: the endpoint for the API call.
  /// - Returns: The data retrieved from the response.
  func delete(endpoint: Endpoint) async throws -> Data
}

public extension Transport {

  func urlRequest(endpoint: Endpoint, method: String, data: Data? = nil) async throws -> URLRequest {

    let url = try await endpoint.url(environment: environment)
    var requestHeaders: [String: String] = [
      HTTPHeader.accept: HTTPContentType.applicationJSON
    ]
    if let data,
       !data.isEmpty {
      requestHeaders[HTTPHeader.contentType] = HTTPContentType.applicationJSON
      requestHeaders[HTTPHeader.contentLength] = String(data.count)
    }
    var request = URLRequest(url: url)
    request.allHTTPHeaderFields = requestHeaders
    request.httpBody = data
    request.httpMethod = method

    request = try await requestProcessors.process(request)

    return request
  }

  func send(endpoint: Endpoint, method: String, data: Data) async throws -> Data {

    let request = try await urlRequest(endpoint: endpoint, method: method, data: data)
    return try await execute(request: request, expectedStatusCodes: [HTTPStatus.created, HTTPStatus.ok, HTTPStatus.noContent])
  }

  func get(endpoint: Endpoint) async throws -> Data {

    let request = try await urlRequest(endpoint: endpoint, method: HTTPMethod.get)
    return try await execute(request: request, expectedStatusCodes: [HTTPStatus.ok])
  }

  func put(endpoint: Endpoint, data: Data) async throws -> Data {

    try await send(endpoint: endpoint, method: HTTPMethod.put, data: data)
  }

  func post(endpoint: Endpoint, data: Data) async throws -> Data {

    try await send(endpoint: endpoint, method: HTTPMethod.post, data: data)
  }

  func delete(endpoint: Endpoint) async throws -> Data {

    let request = try await urlRequest(endpoint: endpoint, method: HTTPMethod.delete)
    return try await execute(request: request, expectedStatusCodes: [HTTPStatus.ok,  HTTPStatus.noContent])
  }
}
