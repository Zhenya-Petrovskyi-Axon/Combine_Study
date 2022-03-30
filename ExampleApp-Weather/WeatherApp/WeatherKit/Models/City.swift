//
//  City.swift
//  WeatherKit
//
//  Created by Ben Scheirman on 9/18/20.
//

import Foundation

public struct City: Codable {
    public let name: String
    public let locality: String
    public let latitude: Double
    public let longitude: Double
    
    public init(name: String, locality: String, latitude: Double, longitude: Double) {
        self.name = name
        self.locality = locality
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension City: Equatable, Hashable {
}
