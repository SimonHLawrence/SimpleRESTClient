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
enum MyEndpoint: Endpoint {
  case users(page: Int?)
  case user(id: Int?)

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
func createUser(name: String, job: String) async throws -> String {
  let endpoint = MyEndpoint.user(id: nil)
  let userRequest = NewUserRequest(name: name, job: job)
  let userResponse: NewUserResponse = try await apiClient.post(endpoint: endpoint, value: userRequest)
  return userResponse.id
}
```

And so on. We can extend the operation of the **Transport** by injecting ``RequestProcessor`` implementations,
for instance to add headers for authentication. These will be executed sequentially but each can operate
asynchronously.

```swift
struct AuthenticationRequestProcessor: RequestProcessor {
  func process(_ request: URLRequest) async throws -> URLRequest {
    // Perform whatever steps are needed to get an access token.
    let accessToken = try await // ...
    let bearer = "Bearer \(accessToken)"
    request.updating(headerFields: [HTTPHeader.authorization: bearer])
  }
}

var transport = NetworkTransport(environment: MyEnvironment.sandbox, 
                           requestProcessors: [AuthenticationRequestProcessor])
```
