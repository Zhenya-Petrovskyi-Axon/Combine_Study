//
//  DailyForecastViewModel.swift
//  WeatherApp
//
//  Created by Ben Scheirman on 9/21/20.
//

import Foundation
import WeatherKit
import UIKit

struct DailyForecastViewModel {
    
    private let dateFormatter: DateFormatter
    private let tempFormatter: MeasurementFormatter
    private let date: Date
    private let metric: WeatherMetrics<DailyTemperatures>
    
    var day: String {
        dateFormatter.string(from: date)
    }
    
    var showsRainChance: Bool {
        probabilityOfPrecipitation > 0
    }
    
    var dailyHigh: String? {
        metric.temp.max.flatMap { tempFormatter.string(from: $0.measurement) }
    }
    
    var dailyLow: String? {
        metric.temp.min.flatMap { tempFormatter.string(from: $0.measurement) }
    }
    
    var chanceOfRain: String {
        String(format: "%.0f%%", probabilityOfPrecipitation)
    }
    
    private var probabilityOfPrecipitation: Float {
        metric.pop ?? 0
    }
    
    var conditionImage: UIImage? {
        metric.weather.first.flatMap { WeatherConditionImage.image(for: $0) }
    }
    
    init(dateFormatter: DateFormatter, tempFormatter: MeasurementFormatter, date: Date, metric: WeatherMetrics<DailyTemperatures>) {
        self.dateFormatter = dateFormatter
        self.tempFormatter = tempFormatter
        self.date = date
        self.metric = metric
    }
}
