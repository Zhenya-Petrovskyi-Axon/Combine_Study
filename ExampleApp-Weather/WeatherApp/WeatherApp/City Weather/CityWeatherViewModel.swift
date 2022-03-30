//
//  CityWeatherViewModel.swift
//  WeatherApp
//
//  Created by Ben Scheirman on 9/18/20.
//

import UIKit
import Combine
import WeatherKit


class CityWeatherViewModel {
    var date: String {
        dateFormatter.string(from: Date())
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    private let city: City
    private let oneCallCache: TimedCache<OneCallResult>
    private let tempFormatter: MeasurementFormatter
    
    @Published var dailyForecast: [DailyForecastViewModel] = []
    
    @Published var hourlyForecast: [HourlyForecastViewModel] = []
    
    private lazy var weatherPublisher: AnyPublisher<OneCallResult?, Never> = {
        Current.weatherManager.weatherPublisher(for: city)
    }()
    
    init(city: City) {
        self.city = city
        oneCallCache = TimedCache()
        
        tempFormatter = MeasurementFormatter()
        tempFormatter.unitStyle = .short
        tempFormatter.numberFormatter = NumberFormatter()
        tempFormatter.numberFormatter.maximumFractionDigits = 1
        
        weatherPublisher
            .map { weather -> [DailyForecastViewModel] in
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE"
                guard let weather = weather else { return [] }
                
                let tempFormatter = MeasurementFormatter()
                tempFormatter.unitStyle = .short
                tempFormatter.numberFormatter.maximumFractionDigits = 0
                
                let viewModels = weather.daily.map { d in
                    return DailyForecastViewModel(dateFormatter: formatter, tempFormatter: tempFormatter, date: d.dt, metric: d)
                }
                
                return viewModels
            }
            .assign(to: &$dailyForecast)
        
        weatherPublisher
            .map { weather -> [HourlyForecastViewModel] in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h a"
                
                let tempFormatter = MeasurementFormatter()
                tempFormatter.numberFormatter.maximumFractionDigits = 0
                tempFormatter.unitStyle = .short
                
                guard let weather = weather else { return [] }
                
                let viewModels = weather.hourly
                    .filter { $0.dt > Date() }
                    .map { h in
                        HourlyForecastViewModel(dateFormatter: dateFormatter, tempFormatter: tempFormatter, date: h.dt, temp: h.temp.measurement)
                    }
                            
                return viewModels
            }
            .assign(to: &$hourlyForecast)
    }
    
    var cityName: String {
        city.name
    }
       
    var currentTemperature: AnyPublisher<String?, Never> {
        weatherPublisher
            .map { [unowned self] weather -> String? in
                guard let weather = weather else { return "---" }
                return tempFormatter.string(from: weather.current.temp.measurement)
            }
            .eraseToAnyPublisher()
    }
    
    var currentConditionImage: AnyPublisher<UIImage?, Never> {
        weatherPublisher
            .map { weather -> UIImage? in
                guard let condition = weather?.current.weather.first else { return nil }
                return WeatherConditionImage.image(for: condition).withRenderingMode(.alwaysTemplate)
            }
            .eraseToAnyPublisher()
            
    }
    
    var currentHighLowTemperature: AnyPublisher<String?, Never> {
        weatherPublisher
            .map { [unowned self] weather in
                guard let today = weather?.daily.first else { return nil }
                guard let min = today.temp.min?.measurement, let max = today.temp.max?.measurement else { return nil }
                let minFormatted = tempFormatter.string(from: min)
                let maxFormatted = tempFormatter.string(from: max)
                return "Low \(minFormatted)  High \(maxFormatted)"
            }
            .eraseToAnyPublisher()
    }
    
    var feelsLike: AnyPublisher<String?, Never> {
        weatherPublisher
            .map { [unowned self] weather in
                guard let weather = weather else { return nil }
                
                let feelsLikeFormatted = tempFormatter.string(from: weather.current.feelsLike.measurement)
                return "Feels like \(feelsLikeFormatted)"
            }
            .eraseToAnyPublisher()
    }
}
