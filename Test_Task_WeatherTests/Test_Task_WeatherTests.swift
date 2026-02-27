//
//  Test_Task_WeatherTests.swift
//  Test_Task_WeatherTests
//
//  Created by developer on 27.02.26.
//

import XCTest
@testable import Test_Task_Weather

private final class WeatherServiceMock: WeatherServiceProtocol {
    var citysResult: Result<[CurrentWeatherItem], Error> = .success([])
    var forecastResultByCity: [String: Result<[ForecastItem], Error>] = [:]
    var currentResultByCity: [String: Result<CurrentWeatherItem, Error>] = [:]

    func fetchCitiesWeather() async throws -> [CurrentWeatherItem] {
        try citysResult.get()
    }

    func fetchCityWeather(city: String) async throws -> CurrentWeatherItem {
        guard let result = currentResultByCity[city] else { throw WeatherServiceError.cityNotFound }
        return try result.get()
    }

    func fetchForecast(city: String) async throws -> [ForecastItem] {
        guard let result = forecastResultByCity[city] else { throw WeatherServiceError.cityNotFound }
        return try result.get()
    }
}

@MainActor
final class CityListViewModelTests: XCTestCase {
    func testShouldHighlightTemperature() async {
        let mock = WeatherServiceMock()
        let viewModel = CityListViewModel(weatherService: mock)
        XCTAssertTrue(viewModel.shouldHighlightTemperature(5))
        XCTAssertFalse(viewModel.shouldHighlightTemperature(10))
        XCTAssertFalse(viewModel.shouldHighlightTemperature(15))
    }
    
    
    func testUpdatesItemsAndCallsOnChange() async {
        let mock = WeatherServiceMock()
        mock.citysResult = .success([
            CurrentWeatherItem(city: "London", temperatureCelsius: 7.5),
            CurrentWeatherItem(city: "Paris", temperatureCelsius: 12.3)
        ])

        let viewModel = CityListViewModel(weatherService: mock)
        let onChangeExpectation = expectation(description: "onChange called")
        viewModel.onChange = {
            onChangeExpectation.fulfill()
        }

        viewModel.load()
        await fulfillment(of: [onChangeExpectation], timeout: 1.0)

        XCTAssertEqual(viewModel.items.count, 2)
        XCTAssertEqual(viewModel.items[0].city, "London")
        XCTAssertEqual(viewModel.items[1].city, "Paris")
        
    }

    func testLoadFailureAndCallsOnError() async {
        let mock = WeatherServiceMock()
        mock.citysResult = .failure(WeatherServiceError.invalidJSON)

        let viewModel = CityListViewModel(weatherService: mock)
        let onErrorExpectation = expectation(description: "onError called")
        viewModel.onError = { message in
            XCTAssertTrue(message.contains("Failed to load weather"))
            onErrorExpectation.fulfill()
        }

        viewModel.load()
        await fulfillment(of: [onErrorExpectation], timeout: 1.0)
    }

    func testUpdatesSpecificIndex() async {
        let mock = WeatherServiceMock()
        mock.citysResult = .success([
            CurrentWeatherItem(city: "London", temperatureCelsius: 7.5),
            CurrentWeatherItem(city: "Paris", temperatureCelsius: 12.3)
        ])
        mock.currentResultByCity["London"] = .success(
            CurrentWeatherItem(city: "London", temperatureCelsius: 8.2)
        )

        let viewModel = CityListViewModel(weatherService: mock)
        let loadExpectation = expectation(description: "load done")
        viewModel.onChange = { loadExpectation.fulfill() }
        viewModel.load()
        await fulfillment(of: [loadExpectation], timeout: 1.0)

        let updateExpectation = expectation(description: "item updated")
        viewModel.onItemUpdated = { index in
            XCTAssertEqual(index, 0)
            updateExpectation.fulfill()
        }
        viewModel.updateItem(at: 0)

        await fulfillment(of: [updateExpectation], timeout: 1.0)
        XCTAssertEqual(viewModel.items[0].temperatureCelsius, 8.2)
    }
}

@MainActor
final class WeatherDetailViewModelTests: XCTestCase {
    func testSectionsByDaysAndSortsItems() async {
        let mock = WeatherServiceMock()
        let calendar = Calendar(identifier: .gregorian)
        let day1morning = calendar.date(from: DateComponents(year: 2026, month: 3, day: 1, hour: 9))!
        let day1evening = calendar.date(from: DateComponents(year: 2026, month: 3, day: 1, hour: 18))!
        let day2noon = calendar.date(from: DateComponents(year: 2026, month: 3, day: 2, hour: 12))!

        mock.forecastResultByCity["London"] = .success([
            ForecastItem(date: day2noon, temperatureCelsius: 11, humidityPercent: 55, pressureHPa: 1008, cloudsPercent: 20, visibility: 10000),
            ForecastItem(date: day1evening, temperatureCelsius: 9, humidityPercent: 60, pressureHPa: 1009, cloudsPercent: 30, visibility: 9000),
            ForecastItem(date: day1morning, temperatureCelsius: 7, humidityPercent: 70, pressureHPa: 1010, cloudsPercent: 40, visibility: 8000)
        ])

        let viewModel = WeatherDetailViewModel(city: "London", weatherService: mock)
        let changeExpectation = expectation(description: "onChange called")
        viewModel.onChange = { changeExpectation.fulfill() }

        viewModel.load()
        await fulfillment(of: [changeExpectation], timeout: 1.0)

        XCTAssertEqual(viewModel.sections.count, 2)
        XCTAssertEqual(viewModel.sections[0].items.count, 2)
        XCTAssertEqual(viewModel.sections[0].items[0].date, day1morning)
        XCTAssertEqual(viewModel.sections[0].items[1].date, day1evening)
        XCTAssertEqual(viewModel.sections[1].items.count, 1)
        XCTAssertEqual(viewModel.sections[1].items[0].date, day2noon)
    }
}
