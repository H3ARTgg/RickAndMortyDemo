import Foundation
import Combine

// MARK: - NetworkClientError
enum NetworkClientError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case parsingError
}

// MARK: - NetworkClient Protocol
protocol NetworkClient {
    func networkPublisher<T: Decodable>(
        request: NetworkRequest,
        type: T.Type
    ) -> AnyPublisher<T, NetworkError>
    
    func networkPublisher(
        request: NetworkRequest
    ) -> AnyPublisher<Data, NetworkError>
}

// MARK: - DefaultNetworkClient
struct DefaultNetworkClient: NetworkClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(decoder: JSONDecoder = JSONDecoder(),
         encoder: JSONEncoder = JSONEncoder()) {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 10
        self.session = URLSession(configuration: sessionConfiguration)
        self.decoder = decoder
        self.encoder = encoder
    }

    // MARK: - Private
    private func create(request: NetworkRequest) -> URLRequest? {
        guard let endpoint = request.endpoint else {
            assertionFailure("Empty endpoint")
            return nil
        }

        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = request.httpMethod.rawValue

        if let dto = request.dto,
           let dtoEncoded = try? encoder.encode(dto) {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = dtoEncoded
        }

        return urlRequest
    }

    private func parse<T: Decodable>(data: Data, type _: T.Type, onResponse: @escaping (Result<T, Error>) -> Void) {
        do {
            let response = try decoder.decode(T.self, from: data)
            onResponse(.success(response))
        } catch {
            onResponse(.failure(NetworkClientError.parsingError))
        }
    }
    
    func networkPublisher<T: Decodable>(request: NetworkRequest, type: T.Type) -> AnyPublisher<T, NetworkError> {
        guard let urlRequest = create(request: request) else {
            return Fail(error: NetworkError.badRequest).eraseToAnyPublisher()
        }
        return session.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: type.self, decoder: decoder)
            .mapError { (error) -> NetworkError in
                switch error {
                case is URLError:
                    return NetworkError.addressUnreachable(request.endpoint)
                default:
                    return NetworkError.invalidResponse
                }
            }
            .eraseToAnyPublisher()
    }
    
    func networkPublisher(request: NetworkRequest) -> AnyPublisher<Data, NetworkError> {
        guard let urlRequest = create(request: request) else {
            return Fail(error: NetworkError.badRequest).eraseToAnyPublisher()
        }
        return session.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .mapError { (error) -> NetworkError in
                NetworkError.addressUnreachable(request.endpoint)
            }
            .eraseToAnyPublisher()
    }
}
