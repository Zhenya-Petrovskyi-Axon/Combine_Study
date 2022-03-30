//
//  DailyWeatherCell.swift
//  WeatherApp
//
//  Created by Ben Scheirman on 9/21/20.
//

import UIKit

class DailyWeatherCell: UICollectionViewCell {
    static let reuseIdentifier = "DailyWeatherCell"
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var chanceOfRainLabel: UILabel!
    @IBOutlet weak var lowTemperatureLabel: UILabel!
    @IBOutlet weak var highTemperatureLabel: UILabel!
}

extension DailyWeatherCell {
    func update(with viewModel: DailyForecastViewModel) {
        dayLabel.text = viewModel.day
        
        if viewModel.showsRainChance {
            chanceOfRainLabel.text = viewModel.chanceOfRain
        } else {
            chanceOfRainLabel.text = ""
        }
        
        lowTemperatureLabel.text = viewModel.dailyLow
        highTemperatureLabel.text = viewModel.dailyHigh
        conditionImageView.image = viewModel.conditionImage
    }
}

