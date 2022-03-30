//
//  WeatherConditionCode.swift
//  WeatherKit
//
//  Created by Ben Scheirman on 9/22/20.
//

import Foundation

public struct WeatherConditionCode: Codable {
    public let code: Int
    public var category: WeatherConditionCategory {
        WeatherConditionCategory.from(code: code)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        code = try container.decode(Int.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(code)
    }
}

public enum WeatherConditionCategory: Int, Codable {
    case thunderstorm
    case drizzle
    case rain
    case snow
    case clouds
    case atmosphere
    case clear
    case unknown
    
    static func from(code: Int) -> WeatherConditionCategory {
        // https://openweathermap.org/weather-conditions#How-to-get-icon-URL
        switch code {
        case 200..<300: return .thunderstorm
        case 300..<400: return .drizzle
        case 500..<600: return .rain
        case 600..<700: return .snow
        case 700..<800: return .atmosphere
        case 800: return .clear
        case 801..<900: return .clouds
        default:
            print("Unmapped condition code: \(code)")
            return .unknown
        }
    }
}
