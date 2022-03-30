//
//  URLHelpers.swift
//  WeatherApp
//
//  Created by Ben Scheirman on 9/18/20.
//

import Foundation

public extension URL {
    func appending(path: String) -> URL {
        appendingPathComponent(path, isDirectory: false)
    }
    
    func appending(queryParams: [String: String]) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        components.queryItems = queryParams.map { key, value in
            URLQueryItem(name: key, value: value)
        }
        return components.url!
    }
}
