# SimpleRESTClient

A simple client for making REST API calls using Swift's async/await feature.

## Usage

First, define an **Environment** in which to make API calls.

```swift
enum MyEnvironment: Environment {
  case sandbox
  case production
  
  var hostName: String {
    switch self {
      case sandbox:
        return "dev.myhost.com"
      case production:
        return "myhost.com"
    }
  }
}
```

Then define an **Endpoint** for the API calls you wish to make:

```swift
enum MyEndpoint {
  case users(page: Int?)
  case user(id: Int?)
}

extension MyEndpoint: Endpoint {

  func url(environment: Environment) async throws -> URL {

    var baseURLComponents = URLComponents()
    baseURLComponents.scheme = "https"
    baseURLComponents.host = environment.hostname
    baseURLComponents.port = environment.portNumber

    guard let baseURL = baseURLComponents.url else {
      throw URLError(.unsupportedURL)
    }

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
    }

    guard let endpointURL = endpointURLComponents.url(relativeTo: baseURL) else {
      throw URLError(.unsupportedURL)
    }

    return endpointURL
  }
}
```

Next, create a **Transport**. For network operations, use **NetworkTransport**. 
For test operations **MockTransport** provides the ability to create mocked responses 
in code or from JSON files. 

You can then inject this transport as a dependency to an API client:

```swift
var transport = NetworkTransport(environment: MyEnvironment.sandbox)
var apiClient = APIClient(transport: transport)
```

Then, we can implement our DTO entities and make calls with the **APIClient**.

```swift
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
```

```swift
let userRequest = NewUserRequest(name: "Noelene", job: "Lead Developer")
let userResponse: NewUserResponse = try await apiClient.post(endpoint: ReqResEndpoint.user(id: nil), value: userRequest)
print("Created user with id \(userResponse.id).")
```

And so on.
