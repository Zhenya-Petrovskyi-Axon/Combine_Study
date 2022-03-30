//
//  CurrentWeatherCell.swift
//  WeatherApp
//
//  Created by Ben Scheirman on 9/21/20.
//

import UIKit
import Combine

class CurrentWeatherCell: UICollectionViewCell {
    static let reuseIdentifier = "CurrentWeatherCell"

    @IBOutlet var cityNameLabel: UILabel!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var lowHighTemperatureLabel: UILabel!
    @IBOutlet var feelsLikeLabel: UILabel!
    @IBOutlet var conditionImageView: UIImageView!
    
    var cancellables = Set<AnyCancellable>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        conditionImageView.alpha = 0.8
    }
}

extension CurrentWeatherCell {
    func update(with viewModel: CityWeatherViewModel) {
        cityNameLabel.text = viewModel.cityName
        
        viewModel.currentTemperature
            .assign(to: \.text, on: temperatureLabel)
            .store(in: &cancellables)
        
        viewModel.currentConditionImage
            .assign(to: \.image, on: conditionImageView)
            .store(in: &cancellables)
        
        viewModel.currentHighLowTemperature
            .assign(to: \.text, on: lowHighTemperatureLabel)
            .store(in: &cancellables)
        
        viewModel.feelsLike
            .assign(to: \.text, on: feelsLikeLabel)
            .store(in: &cancellables)
    }
}
