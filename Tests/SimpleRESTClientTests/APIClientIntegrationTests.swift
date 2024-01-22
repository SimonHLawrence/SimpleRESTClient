//
//  APIClientIntegrationTests.swift
//
//
//  Created by Simon Lawrence on 22/01/2024.
//
import XCTest
@testable import SimpleRESTClient

final class APIClientIntegrationTests: XCTestCase {

  var environment = ReqResEnvironment()
  lazy var transport = NetworkTransport(environment: environment)
  lazy var apiClient = APIClient(transport: transport)
  
  func testGetUsers() async throws {

    let usersResponse: UsersResponse = try await apiClient.get(endpoint: ReqResEndpoint.users(page: 1))

    XCTAssert(!usersResponse.users.isEmpty)
  }

  func testPostUser() async throws {

    let userRequest = NewUserRequest(name: "Noelene", job: "Lead Developer")
    let userResponse: NewUserResponse = try await apiClient.post(endpoint: ReqResEndpoint.user(id: nil), value: userRequest)

    XCTAssert(userResponse.name == userRequest.name)
  }

  func testPostUserIgnoringResponse() async throws {

    let userRequest = NewUserRequest(name: "Noelene", job: "Lead Developer")
    try await apiClient.post(endpoint: ReqResEndpoint.user(id: nil), value: userRequest)
  }

  func testPutUser() async throws {

    let userRequest = UpdateUserRequest(name: "Noelene", job: "Lead Developer")
    let userResponse: UpdateUserResponse = try await apiClient.put(endpoint: ReqResEndpoint.user(id: nil), value: userRequest)

    XCTAssert(userResponse.name == userRequest.name)
  }

  func testPutUserIgnoringResponse() async throws {

    let userRequest = UpdateUserRequest(name: "Noelene", job: "Lead Developer")
    try await apiClient.put(endpoint: ReqResEndpoint.user(id: nil), value: userRequest)
  }

  func testDeleteUser() async throws {

    try await apiClient.delete(endpoint: ReqResEndpoint.user(id: 2))
  }

  func testUnexpectedHTTPResponse() async throws {

    let loginRequest = LoginRequest(email: "jane.doe@yahoo.com")
    do {
      try await apiClient.post(endpoint: ReqResEndpoint.login, value: loginRequest)
    } catch {
      guard let httpError = error as? HTTPError else {
        XCTFail()
        return
      }
      XCTAssert(httpError.code == 400)
      return
    }
    XCTFail()
  }
}
