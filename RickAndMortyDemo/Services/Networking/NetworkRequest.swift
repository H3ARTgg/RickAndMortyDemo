import Foundation

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol NetworkRequest {
    var endpoint: URL? { get }
    var httpMethod: HttpMethod { get }
    var dto: Encodable? { get }
}

extension NetworkRequest {
    var endpoint: URL? { URL(string: "https://rickandmortyapi.com/api/") }
    var httpMethod: HttpMethod { .get }
    var dto: Encodable? { nil }
}
