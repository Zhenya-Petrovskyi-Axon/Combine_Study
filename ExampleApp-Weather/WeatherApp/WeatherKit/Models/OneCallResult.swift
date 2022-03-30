//
//  OneCallResult.swift
//  WeatherKit
//
//  Created by Ben Scheirman on 9/18/20.
//

import Foundation

public struct OneCallResult: Codable {
    public let current: WeatherMetrics<SingleTemperature>
    public let hourly: [WeatherMetrics<SingleTemperature>]
    public let daily: [WeatherMetrics<DailyTemperatures>]
}
