//
//  APIClient.swift
//  SimpleRESTClient
//
//  Created by Simon Lawrence on 20/01/2024.
//

import Foundation

/// A type providing JSON coding for the specific API in use.
public protocol APICoding {
  /// Create a JSON decoder compatible with the API.
  /// - Returns: the decoder.
  func makeDecoder() -> JSONDecoder
  /// Create a JSON encoder compatible with the API.
  /// - Returns: the encoder.
  func makeEncoder() -> JSONEncoder
}

/// Default implementation of ``APICoding``.
public struct DefaultAPICoding: APICoding {

  public init() { }

  public func makeDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
  }

  public func makeEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    return encoder
  }
}

/// A general API client providing REST operations.
public struct APIClient {

  private var transport: Transport
  private var coding: APICoding

  /// Initialize an API client with the supplied transport and coding.
  /// - Parameters:
  ///   - transport: a transport to perform network operations.
  ///   - coding: an instance providing encoding and decoding of JSON data for the particular API.
  public init(transport: Transport, coding: APICoding = DefaultAPICoding()) {
    self.transport = transport
    self.coding = coding
  }

  /// GET an item from the specified endpoint.
  /// - Parameter endpoint: the endpoint to retrieve.
  /// - Returns: the retrieved item.
  public func get<Response: Decodable>(endpoint: Endpoint) async throws -> Response {
    let response = try await transport.get(endpoint: endpoint)
    let jsonDecoder = coding.makeDecoder()
    return try jsonDecoder.decode(Response.self, from: response)
  }

  /// PUT an item to the specified endpoint, retrieving a response.
  /// - Parameters:
  ///   - endpoint: the endpoint to put.
  ///   - value: the value to put.
  /// - Returns: the decoded response.
  public func put<Request: Encodable, Response: Decodable>(endpoint: Endpoint, value: Request) async throws -> Response {
    let jsonEncoder = coding.makeEncoder()
    let request = try jsonEncoder.encode(value)
    let response = try await transport.put(endpoint: endpoint, data: request)
    let jsonDecoder = coding.makeDecoder()
    return try jsonDecoder.decode(Response.self, from: response)
  }

  //// PUT an item to the specified endpoint.
  /// - Parameters:
  ///   - endpoint: the endpoint to put.
  ///   - value: the value to put.
  public func put<Request: Encodable>(endpoint: Endpoint, value: Request) async throws {
    let jsonEncoder = coding.makeEncoder()
    let request = try jsonEncoder.encode(value)
    _ = try await transport.put(endpoint: endpoint, data: request)
  }

  /// POST an item to the specified endpoint, retrieving a response.
  /// - Parameters:
  ///   - endpoint: the endpoint to post.
  ///   - value: the value to put.
  /// - Returns: the decoded response.
  public func post<Request: Encodable, Response: Decodable>(endpoint: Endpoint, value: Request) async throws -> Response {
    let jsonEncoder = coding.makeEncoder()
    let request = try jsonEncoder.encode(value)
    let response = try await transport.post(endpoint: endpoint, data: request)
    let jsonDecoder = coding.makeDecoder()
    return try jsonDecoder.decode(Response.self, from: response)
  }

  /// POST an item to the specified endpoint.
  /// - Parameters:
  ///   - endpoint: the endpoint to post.
  ///   - value: the value to put.
  public func post<Request: Encodable>(endpoint: Endpoint, value: Request) async throws {
    let jsonEncoder = coding.makeEncoder()
    let request = try jsonEncoder.encode(value)
    _ = try await transport.post(endpoint: endpoint, data: request)
  }

  /// DELETE the specified item, retrieving a response.
  /// - Parameter endpoint: the endpoint to delete.
  /// - Returns: the decoded response.
  public func delete<Response: Decodable>(endpoint: Endpoint) async throws -> Response {
    let response = try await transport.delete(endpoint: endpoint)
    let jsonDecoder = coding.makeDecoder()
    return try jsonDecoder.decode(Response.self, from: response)
  }

  /// DELETE the specified item.
  /// - Parameter endpoint: the endpoint to delete.
  public func delete(endpoint: Endpoint) async throws {
    _ = try await transport.delete(endpoint: endpoint)
  }
}
