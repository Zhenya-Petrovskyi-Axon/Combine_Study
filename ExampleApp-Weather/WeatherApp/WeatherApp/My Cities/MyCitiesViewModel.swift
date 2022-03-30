//
//  MyCitiesViewModel.swift
//  WeatherApp
//
//  Created by Ben Scheirman on 9/29/20.
//

import Foundation
import UIKit
import WeatherKit
import Combine

class MyCitiesViewModel {
    enum Section: Int {
        case cities
    }
    
    private let tempFormatter = MeasurementFormatter()
    
    init() {
        tempFormatter.numberFormatter.maximumFractionDigits = 0
    }
    
    private var appState: AppState {
        Current.appState
    }
    
    private var citiesStore: CitiesStore {
        Current.citiesStore
    }
    
    private var cities: AnyPublisher<[CityViewModel], Never> {
        appState.$cityWeathers
            .map { [tempFormatter] (weathers: [CityWeather]) in
                weathers.map { CityViewModel(city: $0.city, weather: $0.weather, tempFormatter: tempFormatter)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func contextMenu(for index: Int) -> UIMenu {
        let city = citiesStore.cities[index]
        let action = UIAction(title: "Delete City", attributes: [.destructive]) { [weak self] action in
            self?.remove(city: city)
        }
        
        let menu = UIMenu(title: "\(city.name)", options: [], children: [action])
        return menu
    }
    
    func remove(city: City) {
        citiesStore.remove(city)
    }
    
    var snapshotPublisher: AnyPublisher<NSDiffableDataSourceSnapshot<Section, CityViewModel>, Never> {
        cities.map { cities in
            var snapshot = NSDiffableDataSourceSnapshot<Section, CityViewModel>()
            snapshot.appendSections([.cities])
            snapshot.appendItems(cities)
            return snapshot
        }
        .eraseToAnyPublisher()
    }
}
