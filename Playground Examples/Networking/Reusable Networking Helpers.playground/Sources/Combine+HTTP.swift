import Foundation
import Combine

public enum HttpError: Error {
    case nonHttpResponse
    case requestFailed(Int)
    case serverError(Int)
    case networkingError(Error)
    case decodingError(DecodingError)
    
    var isRetriable: Bool {
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

extension Publisher where Output == (data: Data, response: URLResponse) {
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
