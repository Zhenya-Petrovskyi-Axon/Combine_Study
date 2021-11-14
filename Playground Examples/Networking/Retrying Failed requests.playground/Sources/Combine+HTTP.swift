import Foundation
import Combine

public enum HttpError: Error {
    case nonHttpResponse
    case requestFailed(Int)
    case serverError(Int)
    case networkingError(Error)
    case decodingError(DecodingError)
    
    public var isRetriable: Bool {
        switch self {
        case .decodingError(_):
            return false
        case .requestFailed(let status):
            let timestatus = 408
            let rateLimitStatus = 429
            return [timestatus, rateLimitStatus].contains(status)
        case .serverError, .networkingError, .nonHttpResponse:
            return true
        }
    }
}

public extension Publisher where Output == (data: Data, response: URLResponse) {
    func assumeHTTP() -> AnyPublisher<(data: Data, response: HTTPURLResponse), HttpError> {
        tryMap { (data: Data, response: URLResponse) -> (Data, HTTPURLResponse) in
            guard let response = response as? HTTPURLResponse else {
                throw HttpError.nonHttpResponse
            }
            return (data, response)
        }
        .mapError { error in
            if error is HttpError {
                return error as! HttpError
            } else {
                return HttpError.networkingError(error)
            }
        }
        .eraseToAnyPublisher()
    }
}

public extension Publisher where Output == (data: Data, response: HTTPURLResponse), Failure == HttpError {
    func responseData() -> AnyPublisher<Data, HttpError> {
        tryMap { (data: Data, response: HTTPURLResponse) -> Data in
            switch response.statusCode {
            case 200: return data
            case 400...499: throw HttpError.requestFailed(response.statusCode)
            case 500...599: throw HttpError.serverError(response.statusCode)
            default: fatalError("Unhandled HTTP Response status code: \(response.statusCode)")
            }
        }
        .mapError { $0 as! HttpError }
        .eraseToAnyPublisher()
    }
}

public extension Publisher where Output == Data, Failure == HttpError {
    func decoding<Item, Coder>(type: Item.Type, decoder: Coder) -> AnyPublisher<Item, HttpError> where Item: Decodable, Coder: TopLevelDecoder, Self.Output == Coder.Input {
        decode(type: type, decoder: decoder)
        .mapError { error in
            if error is DecodingError {
                return HttpError.decodingError(error as! DecodingError)
            } else {
                return error as! HttpError
            }
        }
        .eraseToAnyPublisher()
    }
}
