//
//  CityWeather.swift
//  WeatherApp
//
//  Created by Ben Scheirman on 9/29/20.
//

import Foundation
import Combine
import WeatherKit

struct CityWeather {
    let city: City
    let weather: AnyPublisher<OneCallResult?, Never>
}
