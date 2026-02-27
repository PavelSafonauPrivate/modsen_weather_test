//
//  CityListViewModel.swift
//  Test_Task_Weather
//
//  Created by developer on 27.02.26.
//

import Foundation

@MainActor
final class CityListViewModel {
    private let weatherService: WeatherServiceProtocol

    private(set) var items: [CurrentWeatherItem] = []
    var onChange: (() -> Void)?
    var onItemUpdated: ((Int) -> Void)?
    var onError: ((String) -> Void)?

    init(weatherService: WeatherServiceProtocol) {
        self.weatherService = weatherService
    }

    func load() {
        Task {
            do {
                items = try await weatherService.fetchCitiesWeather()
                onChange?()
            } catch {
                onError?("Failed to load weather: \(error.localizedDescription)")
            }
        }
    }

    func item(at index: Int) -> CurrentWeatherItem {
        items[index]
    }

    func shouldHighlightTemperature(_ temperature: Double) -> Bool {
        temperature < 10.0
    }

    func updateItem(at index: Int) {
        guard items.indices.contains(index) else { return }

        let city = items[index].city
        Task {
            do {
                let updated = try await weatherService.fetchCityWeather(city: city)
                items[index] = updated
                onItemUpdated?(index)
            } catch {
                onError?("Failed to update \(city): \(error.localizedDescription)")
            }
        }
    }
}
