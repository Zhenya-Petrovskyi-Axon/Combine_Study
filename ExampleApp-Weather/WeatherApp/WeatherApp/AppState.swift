//
//  AppState.swift
//  WeatherApp
//
//  Created by Ben Scheirman on 9/29/20.
//

import Foundation
import Combine
import WeatherKit

class AppState {
    @Published var cityWeathers: [CityWeather] = []
    
    func load(citiesStore: CitiesStore, weatherManager: WeatherManager) {
        
        citiesStore.$cities
            .map { cities in
                cities.map { city in
                    CityWeather(city: city, weather: weatherManager.weatherPublisher(for: city))
                }
            }
            .assign(to: &$cityWeathers)
    }
}
