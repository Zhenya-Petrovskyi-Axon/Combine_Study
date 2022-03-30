//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by Ben Scheirman on 9/18/20.
//

import Foundation
import WeatherKit
import Combine


class WeatherManager {
    private let cache: TimedCache<OneCallResult>
    private var publishers: [City: CurrentValueSubject<OneCallResult?, Never>] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        cache = TimedCache()
    }
        
    func weatherPublisher(for city: City) -> AnyPublisher<OneCallResult?, Never> {
        if let existing = publishers[city] {
            return existing.eraseToAnyPublisher()
        }
        
        let subject = CurrentValueSubject<OneCallResult?, Never>(nil)
        publishers[city] = subject
        
        fetchWeather(for: city, subject: subject)
        return subject
            .eraseToAnyPublisher()
    }
    
    private func fetchWeather(for city: City, subject: CurrentValueSubject<OneCallResult?, Never>) {
        let cacheKey = ["onecall", String(format: "lat:%.2f", city.latitude), String(format: "long:%.2f", city.longitude)].joined(separator: "|")
        
        if let cached = cache.get(cacheKey: cacheKey) {
            subject.send(cached)
        } else {
            Current.weatherAPI.oneCallForecast(lat: city.latitude, long: city.longitude)
                .handleEvents(
                    receiveSubscription: { _ in
                        print("Fetching Weather for \(city.name)...")
                    })
                .map { $0 as OneCallResult? }
                .catch { error -> Just<OneCallResult?> in
                    print("ERROR! \(error)")
                    return Just(nil)
                }
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] weather in
                    if let weather = weather {
                        cache.set(cacheKey: cacheKey, model: weather, expires: Date().addingTimeInterval(60 * 60))
                    }
                    
                    subject.send(weather)
                }
                .store(in: &cancellables)
        }
    }
}
