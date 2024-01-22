//
//  ReqResEndpoint.swift
//  
//
//  Created by Simon Lawrence on 22/01/2024.
//

import Foundation
import SimpleRESTClient

enum ReqResEndpoint {
  case users(page: Int?)
  case user(id: Int?)
  case login
}

extension ReqResEndpoint: Endpoint {

  func url(environment: Environment) async throws -> URL {

    var baseURLComponents = URLComponents()
    baseURLComponents.scheme = "https"
    baseURLComponents.host = environment.hostname
    baseURLComponents.port = environment.portNumber

    guard let baseURL = baseURLComponents.url else {
      throw URLError(.unsupportedURL)
    }

    print(baseURL.absoluteString)
    var endpointURLComponents = URLComponents()

    switch self {
    case .users(page: let page):
      endpointURLComponents.path = "/api/users/"
      if let page {
        endpointURLComponents.queryItems = [URLQueryItem(name: "page", value: String(page))]
      }
    case .user(id: let id):
      if let id {
        endpointURLComponents.path = "/api/users/\(id)"
      } else {
        endpointURLComponents.path = "/api/users/"
      }
    case .login:
      endpointURLComponents.path = "/api/login"
    }

    guard let endpointURL = endpointURLComponents.url(relativeTo: baseURL) else {
      throw URLError(.unsupportedURL)
    }

    print(endpointURL.absoluteString)
    return endpointURL
  }
}
