//
//  HTTPDefinitions.swift
//  SimpleRESTClient
//
//  Created by Simon Lawrence on 20/01/2024.
//

import Foundation

public struct HTTPMethod {

  static var get = "GET"
  static var delete = "DELETE"
  static var post = "POST"
  static var put = "PUT"
}

public struct HTTPStatus {

  static var ok = 200
  static var created = 201
  static var noContent = 204
}

public struct HTTPHeader {

  static var contentType = "Content-Type"
  static var contentLength = "Content-Length"
  static var accept = "Accept"
  static var location = "Location"
  static var authorization = "Authorization"
}

public struct HTTPContentType {

  static var applicationJSON = "application/json"
}

public extension URLRequest {

  func updating(headerFields: [String: String]) -> URLRequest {
    var updatedHeaderFields = allHTTPHeaderFields ?? [:]
    headerFields.forEach { updatedHeaderFields[$0.key] = $0.value }
    var updatedRequest = self
    updatedRequest.allHTTPHeaderFields = updatedHeaderFields
    return updatedRequest
  }
}

public struct HTTPError: Error {

  public let code: Int

  public init(code: Int) {
    self.code = code
  }
}

extension HTTPError: LocalizedError {

  public var errorDescription: String? {
    HTTPURLResponse.localizedString(forStatusCode: code)
  }
}
