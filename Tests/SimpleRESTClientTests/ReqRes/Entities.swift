//
//  File.swift
//  
//
//  Created by Simon Lawrence on 22/01/2024.
//

import Foundation

struct User: Codable {

  enum CodingKeys: String, CodingKey {
    case id
    case email
    case firstName = "first_name"
    case lastName = "last_name"
    case avatar
  }

  let id: Int
  let email: String
  let firstName: String
  let lastName: String
  let avatar: URL
}

struct UsersResponse: Codable {

  enum CodingKeys: String, CodingKey {
    case page
    case perPage = "per_page"
    case total
    case totalPages = "total_pages"
    case users = "data"
  }

  var page: Int
  var perPage: Int
  var total: Int
  var totalPages: Int
  var users: [User]
}

struct NewUserRequest: Codable {
  var name: String
  var job: String
}

struct NewUserResponse: Codable {
  var name: String
  var job: String
  var id: String
  var createdAt: String
}

struct UpdateUserRequest: Codable {
  var name: String
  var job: String
}

struct UpdateUserResponse: Codable {
  var name: String
  var job: String
  var updatedAt: String
}

struct LoginRequest: Codable {
  var email: String
}
