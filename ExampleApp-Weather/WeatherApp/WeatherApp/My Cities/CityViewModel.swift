//
//  CityViewModel.swift
//  WeatherApp
//
//  Created by Ben Scheirman on 9/23/20.
//

import Foundation
import UIKit
import WeatherKit
import Combine

class CityViewModel: Equatable, Hashable {
    private let city: City
    private let weather: AnyPublisher<OneCallResult?, Never>
    
    init(city: City, weather: AnyPublisher<OneCallResult?, Never>, tempFormatter: MeasurementFormatter) {
        self.city = city
        self.weather = weather
        
        weather
            .compactMap { weather in
                guard let weather = weather else { return nil }
                return tempFormatter.string(from: weather.current.temp.measurement)
            }
            .assign(to: &$currentTemperature)
    }
    
    var cityName: String {
        city.name
    }
    
    var cityLocality: String {
        city.locality
    }
    
    @Published var currentTemperature: String = "--°"
}

extension CityViewModel {
    static func ==(lhs: CityViewModel, rhs: CityViewModel) -> Bool {
        return lhs.city == rhs.city
    }
    
    func hash(into hasher: inout Hasher) {
        city.hash(into: &hasher)
    }
}
