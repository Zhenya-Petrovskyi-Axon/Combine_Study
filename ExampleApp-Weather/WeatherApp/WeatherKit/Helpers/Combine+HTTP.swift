//
//  Combine+HTTP.swift
//  WeatherKit
//
//  Created by Ben Scheirman on 9/18/20.
//

import Foundation
import Combine

public enum HTTPError: Error {
    case nonHTTPResponse
    case requestFailed(Int)
    case serverError(Int)
    case networkError(Error)
    case decodingError(DecodingError)
    case unhandledResponse(String)
    
    public var isRetriable: Bool {
        switch self {
        case .decodingError, .unhandledResponse:
            return false
            
        case .requestFailed(let status):
            let timeoutStatus = 408
            let rateLimitStatus = 429
            return [timeoutStatus, rateLimitStatus].contains(status)
            
        case .serverError, .networkError, .nonHTTPResponse:
            return true
        }
    }
}

public extension Publisher where Output == (data: Data, response: URLResponse) {
    func assumeHTTP() -> AnyPublisher<(data: Data, response: HTTPURLResponse), HTTPError> {
        tryMap { (data: Data, response: URLResponse) in
            guard let http = response as? HTTPURLResponse else { throw HTTPError.nonHTTPResponse }
            return (data, http)
        }
        .mapError { error in
            if error is HTTPError {
                return error as! HTTPError
            } else {
                return HTTPError.networkError(error)
            }
        }
        .eraseToAnyPublisher()
    }
}

public extension Publisher where
    Output == (data: Data, response: HTTPURLResponse),
    Failure == HTTPError {
    
    func responseData() -> AnyPublisher<Data, HTTPError> {
        tryMap { (data: Data, response: HTTPURLResponse) -> Data in
            switch response.statusCode {
            case 200...299: return data
            case 400...499: throw HTTPError.requestFailed(response.statusCode)
            case 500...599: throw HTTPError.serverError(response.statusCode)
            default:
                throw HTTPError.unhandledResponse("Unhandled HTTP Response Status code: \(response.statusCode)")
            }
        }
        .mapError { $0 as! HTTPError }
        .eraseToAnyPublisher()
    }
}

public extension Publisher where Output == Data, Failure == HTTPError {
    func decoding<T : Decodable, Decoder: TopLevelDecoder>(_ type: T.Type, decoder: Decoder) -> AnyPublisher<T, HTTPError> where Decoder.Input == Data {
        decode(type: T.self, decoder: decoder)
            .mapError { error in
                if error is DecodingError {
                    return HTTPError.decodingError(error as! DecodingError)
                } else {
                    return error as! HTTPError
                }
            }
            .eraseToAnyPublisher()
    }
}

