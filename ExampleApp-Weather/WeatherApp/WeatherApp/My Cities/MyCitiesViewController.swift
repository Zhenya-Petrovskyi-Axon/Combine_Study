//
//  MyCitiesViewController.swift
//  WeatherApp
//
//  Created by Ben Scheirman on 9/18/20.
//

import UIKit
import WeatherKit
import Combine

class MyCitiesViewController: UICollectionViewController {
    
    private var viewModel = MyCitiesViewModel()
    private var chosenCityCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
    private var diffableDatasource: UICollectionViewDiffableDataSource<MyCitiesViewModel.Section, CityViewModel>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCityTapped))
        
        collectionView.collectionViewLayout = MyCitiesLayout.createLayout()
        collectionView.backgroundView = GradientView(colors: [.systemBlue, .systemTeal])
        
        diffableDatasource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { (cv, indexPath, viewModel) -> UICollectionViewCell? in
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "CityCell", for: indexPath) as! CityCell
            cell.update(with: viewModel)
            return cell
        })
        
        viewModel.snapshotPublisher
            .sink { [weak self] snapshot in
                self?.diffableDatasource.apply(snapshot, animatingDifferences: true)
            }
            .store(in: &cancellables)
    }
    
    @objc private func addCityTapped() {
        let addCityVC = AddCityViewController()
        let addCityNav = UINavigationController(rootViewController: addCityVC)
        present(addCityNav, animated: true, completion: nil)
        
        chosenCityCancellable = addCityVC
            .$chosenCity
            .dropFirst()
            .sink(receiveValue: { city in
                addCityNav.dismiss(animated: true, completion: nil)
                if let city = city {
                    Current.citiesStore.add(city)
                }
            })
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCity" {
            guard let index = collectionView.indexPathsForSelectedItems?.first?.row else { return }
            let city = Current.citiesStore.cities[index]
            let cityVC = segue.destination as! CityWeatherViewController
            cityVC.city = city
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let menu = viewModel.contextMenu(for: indexPath.row)
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
            return menu
        })
    }
}
