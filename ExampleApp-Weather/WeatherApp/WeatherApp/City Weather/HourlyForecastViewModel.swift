//
//  HourlyForecastViewModel.swift
//  WeatherApp
//
//  Created by Ben Scheirman on 9/23/20.
//

import Foundation

class HourlyForecastViewModel {
    private let dateFormatter: DateFormatter
    private let tempFormatter: MeasurementFormatter
    
    private let date: Date
    private let temp: Measurement<UnitTemperature>
    
    init(dateFormatter: DateFormatter, tempFormatter: MeasurementFormatter, date: Date, temp: Measurement<UnitTemperature>) {
        self.dateFormatter = dateFormatter
        self.tempFormatter = tempFormatter
        self.date = date
        self.temp = temp
    }
    
    var time: String {
        if abs(Date().distance(to: date)) < 60 * 60 {
            return "Now"
        } else {
            return dateFormatter.string(from: date)
                .lowercased()
        }
    }
    
    var temperature: String {
        tempFormatter.string(from: temp)
    }
}
