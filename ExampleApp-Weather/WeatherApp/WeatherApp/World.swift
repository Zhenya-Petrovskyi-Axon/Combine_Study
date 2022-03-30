//
//  World.swift
//  WeatherApp
//
//  Created by Ben Scheirman on 9/18/20.
//

import Foundation
import WeatherKit

struct World {
    var appState: AppState
    var citiesStore: CitiesStore
    var weatherAPI: OpenWeatherMapAPIClient
    var weatherManager: WeatherManager
}

var Current = World(
    appState: AppState(),
    citiesStore: CitiesStore.load(),
    weatherAPI: OpenWeatherMapAPIClient(),
    weatherManager: WeatherManager()
)
