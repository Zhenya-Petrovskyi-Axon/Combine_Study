//
//  WeatherCondition.swift
//  WeatherKit
//
//  Created by Ben Scheirman on 9/18/20.
//

import Foundation

public protocol TemperatureContainer: Codable {}

public struct SingleTemperature: TemperatureContainer {
    public let measurement: Measurement<UnitTemperature>
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(Double.self)
        measurement = Measurement(value: value, unit: .kelvin)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(measurement.value)
    }
}

public struct DailyTemperatures: TemperatureContainer {
    public let day: SingleTemperature
    public let min: SingleTemperature?
    public let max: SingleTemperature?
    public let night: SingleTemperature
    public let eve: SingleTemperature
    public let morn: SingleTemperature
}

public struct WeatherMetrics<Temperature: TemperatureContainer>: Codable {
    public let dt: Date
    public let temp: Temperature
    public let feelsLike: Temperature
    public let pressure: Int
    public let humidity: Int
    public let weather: [WeatherCondition]
    public let pop: Float?
}

public struct WeatherCondition: Codable {
    public let id: WeatherConditionCode
    public let main: String
    public let description: String
    public let icon: String
}
