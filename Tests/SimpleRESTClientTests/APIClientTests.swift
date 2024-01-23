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
  lazy var transport = MockTransport(environment: environment)
  lazy var apiClient = APIClient(transport: transport)
  lazy var sourceFolder = {
    let thisFile = URL(fileURLWithPath: #file)
    let thisDirectory = thisFile.deletingLastPathComponent()
    return thisDirectory.appendingPathComponent("Data", isDirectory: true)
  }()

  override func setUp() async throws {
    transport.clear()
  }

  func testDeleteWithResponse() async throws {

    guard let deleteResponse = MockResponse(statusCode: 200, filename: "DeleteResponse", sourceFolder: sourceFolder) else {
      XCTFail()
      return
    }
    let deleteRequest = ExpectedRequest(url: "https://www.google.com", method: "DELETE", response: deleteResponse)
    transport.expect(deleteRequest)
    let result: DeleteResponse = try await apiClient.delete(endpoint: DeleteEndpoint())
    XCTAssert(!result.errors.isEmpty)
    XCTAssertEqual(result.errors.first, "No worries.")
    XCTAssertTrue(transport.allExpectedRequestsReceived)
  }

  func testGet() async throws {

    let usersResponse = UsersResponse(page: 1, perPage: 10, total: 2, totalPages: 1, users: [
      User(id: 1, email: "jane.doe@gmail.com", firstName: "Jane", lastName: "Doe", avatar: URL(string: "https://www.google.com")!),
      User(id: 2, email: "nitin.sawhney@gmail.com", firstName: "Nitin", lastName: "Sawhney", avatar: URL(string: "https://www.google.com")!)])
    let jsonEncoder = DefaultAPICoding().makeEncoder()
    let encodedResponse = (try? jsonEncoder.encode(usersResponse)) ?? Data()
    let usersRequest = ExpectedRequest(url: "https://reqres.in/api/users/?page=1", method: "GET", response: MockResponse(statusCode: 200, body: encodedResponse))
    transport.expect(usersRequest)
    let result: UsersResponse = try await apiClient.get(endpoint: ReqResEndpoint.users(page: 1))
    XCTAssert(result.users.count == 2)
  }

  func testGetWith404() async throws {

    let usersRequest = ExpectedRequest(url: "https://reqres.in/api/users/?page=1",
                                       method: "GET",
                                       response: MockResponse(statusCode: 404, body: Data()))
    transport.expect(usersRequest)
    do {
      let result: UsersResponse = try await apiClient.get(endpoint: ReqResEndpoint.users(page: 1))
      print(result)
      XCTFail()
    } catch {
      XCTAssertTrue(error is HTTPError)
      if let httpError = error as? HTTPError {
        XCTAssertEqual(httpError.code, 404)
      }
    }
  }
}
