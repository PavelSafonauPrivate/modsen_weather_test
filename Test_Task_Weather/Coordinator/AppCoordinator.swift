//
//  AppCoordinator.swift
//  Test_Task_Weather
//
//  Created by developer on 27.02.26.
//

import UIKit

final class AppCoordinator: Coordinator {
    let navigationController: UINavigationController

    private let weatherService: WeatherServiceProtocol

    init(navigationController: UINavigationController, weatherService: WeatherServiceProtocol) {
        self.navigationController = navigationController
        self.weatherService = weatherService
    }

    func start() {
        let viewModel = CityListViewModel(weatherService: weatherService)
        let viewController = CityListViewController(viewModel: viewModel)
        viewController.onCitySelected = { [weak self] city in
            self?.showDetails(for: city)
        }
        navigationController.setViewControllers([viewController], animated: false)
    }

    private func showDetails(for city: String) {
        let viewModel = WeatherDetailViewModel(city: city, weatherService: weatherService)
        let viewController = WeatherDetailViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
