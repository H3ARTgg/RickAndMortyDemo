import Foundation

// MARK: - HttpMethod
enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - NetworkRequest
protocol NetworkRequest {
    var endpoint: URL? { get }
    var httpMethod: HttpMethod { get }
    var dto: Encodable? { get }
}

// MARK: - NetworkRequest Extension
extension NetworkRequest {
    var endpoint: URL? { URL(string: "https://rickandmortyapi.com/api/") }
    var httpMethod: HttpMethod { .get }
    var dto: Encodable? { nil }
}
