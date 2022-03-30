//
//  OpenWeatherMapAPIClient.swift
//  WeatherKit
//
//  Created by Ben Scheirman on 9/18/20.
//

import Foundation
import Combine

public class OpenWeatherMapAPIClient {
    var session: URLSession = .shared
    
    private var apiKey: String
    private var baseURL = URL(string: "https://api.openweathermap.org/data/2.5")!
    
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    public convenience init() {
        guard let infoPlistAPIKey = Bundle.main.infoDictionary?["OpenWeatherMapApiKey"] as? String else {
            fatalError("You must supply API key either in the initializer or in the Info.plist under `OpenWeatherMapApiKey`")
        }
        self.init(apiKey: infoPlistAPIKey)
    }
    
    public func oneCallForecast(lat: Double, long: Double) -> AnyPublisher<OneCallResult, HTTPError> {
        let url = baseURL
            .appending(path: "onecall")
            .appending(queryParams: [
                "appid": apiKey,
                "lat": "\(lat)",
                "lon": "\(long)",
            ])
        
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
            
        return fetchResource(OneCallResult.self, with: request)
    }
    
    private func fetchResource<R: Decodable>(_ type: R.Type, with request: URLRequest) -> AnyPublisher<R, HTTPError> {
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return session.dataTaskPublisher(for: request)
            .assumeHTTP()
            .responseData()
            .decoding(R.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}
