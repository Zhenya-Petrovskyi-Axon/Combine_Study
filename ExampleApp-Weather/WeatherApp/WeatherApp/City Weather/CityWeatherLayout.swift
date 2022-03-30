//
//  CityWeatherLayout.swift
//  WeatherApp
//
//  Created by Ben Scheirman on 9/18/20.
//

import UIKit

struct CityWeatherLayout {
    
    enum DecorationKind: String {
        case sectionBackground = "section-decoration-background"
    }
    
    enum Section: Int {
        case currentWeather
        case hourlyForecast
        case weeklyForecast
    }
    
    static func createLayout() -> UICollectionViewCompositionalLayout {
        let sections = [currentWeatherSection(), hourlyForecastSection(), weeklyForecastSection()]
        let layout = UICollectionViewCompositionalLayout { index, environment -> NSCollectionLayoutSection? in
            sections[index]
        }
        
        layout.register(SectionSeparatorView.self, forDecorationViewOfKind: DecorationKind.sectionBackground.rawValue)
        return layout
    }
    
    private static func currentWeatherSection() -> NSCollectionLayoutSection {
        let currentWeatherItem = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        
        let currentWeatherGroup = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)), subitems: [currentWeatherItem])
        
        return NSCollectionLayoutSection(group: currentWeatherGroup)
    }

    private static func hourlyForecastSection() -> NSCollectionLayoutSection {
        let hourlyItem = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1/7), heightDimension: .fractionalHeight(1)))
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80)),
            subitems: [hourlyItem])

        let section = NSCollectionLayoutSection(group: group)
        section.decorationItems = [
            NSCollectionLayoutDecorationItem.background(elementKind: DecorationKind.sectionBackground.rawValue)
        ]
        return section
    }
    
    private static func weeklyForecastSection() -> NSCollectionLayoutSection {
        let dayItem = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), subitems: [dayItem])
        return NSCollectionLayoutSection(group: group)
    }
    
}
