//
//  WeatherService.swift
//  Test_Task_Weather
//
//  Created by developer on 27.02.26.
//

import Foundation

protocol WeatherServiceProtocol {
    func fetchCitiesWeather() async throws -> [CurrentWeatherItem]
    func fetchCityWeather(city: String) async throws -> CurrentWeatherItem
    func fetchForecast(city: String) async throws -> [ForecastItem]
}

final class WeatherService: WeatherServiceProtocol {
    private let session: URLSession
    private let apiKey: String
    private let cities: [City]

    init(session: URLSession = .shared, apiKey: String, cities: [City]) {
        self.apiKey = apiKey
        self.session = session
        self.cities = cities
    }

    func fetchCitiesWeather() async throws -> [CurrentWeatherItem] {
        var results: [CurrentWeatherItem] = []
        try await withThrowingTaskGroup(of: CurrentWeatherItem.self) { [weak self] group in
            guard let self else { return }
            for city in cities {
                group.addTask { [session, apiKey] in
                    try await self.fetchCurrentWeather(for: city, session: session, apiKey: apiKey)
                }
            }

            for try await weather in group {
                results.append(weather)
            }
        }

        return results.sorted(by: { $0.city < $1.city })
    }

    func fetchCityWeather(city: String) async throws -> CurrentWeatherItem {
        guard let city = cities.first(where: { $0.name == city }) else { throw WeatherServiceError.cityNotFound }
        return try await fetchCurrentWeather(for: city, session: session, apiKey: apiKey)
    }

    func fetchForecast(city: String) async throws -> [ForecastItem] {
        guard let city = cities.first(where: { $0.name == city }) else { throw WeatherServiceError.cityNotFound }
        return try await fetchForecast(for: city, session: session, apiKey: apiKey)
    }

    private func fetchCurrentWeather(for city: City, session: URLSession, apiKey: String) async throws -> CurrentWeatherItem {
        guard var components = URLComponents(string: urlString(for: .currentWeather)) else { throw WeatherServiceError.invalidURL }
        
        components.queryItems = queryItems(for: city)
        
        guard let url = components.url else { throw WeatherServiceError.invalidURL }
        
        let (data, _) = try await session.data(from: url)

        guard let jsonText = String(data: data, encoding: .utf8),
              BridgeWrapper.isValidJSON(jsonText) else { throw WeatherServiceError.invalidJSON }

        guard let temperature = BridgeWrapper.doubleValue(forPath: "main.temp", inJSON: jsonText)?.doubleValue
        else { throw WeatherServiceError.parseFailed }

        return CurrentWeatherItem(city: city.name,
                                  temperatureCelsius: temperature)
    }

    private func fetchForecast(for city: City, session: URLSession, apiKey: String) async throws -> [ForecastItem] {
        guard var components = URLComponents(string: urlString(for: .forecast)) else { throw WeatherServiceError.invalidURL }
        components.queryItems = queryItems(for: city)

        guard let url = components.url else { throw WeatherServiceError.invalidURL }
        let (data, _) = try await session.data(from: url)
        
        guard let jsonText = String(data: data, encoding: .utf8),
              BridgeWrapper.isValidJSON(jsonText) else { throw WeatherServiceError.invalidJSON }
        var items: [ForecastItem] = []
        var index = 0
        while true {
            let prefix = "list[\(index)]"
            
            guard let temperature = BridgeWrapper.doubleValue(forPath: "\(prefix).main.temp", inJSON: jsonText)?.doubleValue else { break }
            
            let strategy = Date.ParseStrategy(
                format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits) \(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):00:00",
                timeZone: .current)
            
            guard let pressure = BridgeWrapper.intValue(forPath: "\(prefix).main.pressure", inJSON: jsonText)?.intValue,
                  let humidity = BridgeWrapper.intValue(forPath: "\(prefix).main.humidity", inJSON: jsonText)?.intValue,
                  let visibility = BridgeWrapper.intValue(forPath: "\(prefix).visibility", inJSON: jsonText)?.intValue,
                  let clouds = BridgeWrapper.intValue(forPath: "\(prefix).clouds.all", inJSON: jsonText)?.intValue,
                  let dateText = BridgeWrapper.stringValue(forPath: "\(prefix).dt_txt", inJSON: jsonText),
                  let date = try? Date(dateText, strategy: strategy)
            else { index += 1; continue }
            
            items.append(
                ForecastItem(date: date,
                             temperatureCelsius: temperature,
                             humidityPercent: humidity,
                             pressureHPa: pressure,
                             cloudsPercent: clouds,
                             visibility: visibility)
            )

            index += 1
        }

        guard !items.isEmpty else { throw WeatherServiceError.parseFailed }
        return items
    }
    
    enum FetchType {
        case currentWeather
        case forecast
    }
    
    private func urlString(for type: FetchType) -> String {
        return switch type {
        case .currentWeather: "https://api.openweathermap.org/data/2.5/weather"
        case .forecast: "https://api.openweathermap.org/data/2.5/forecast"
        }
    }
    
    private func queryItems(for city: City) -> [URLQueryItem] {
        [
            URLQueryItem(name: "q", value: "\(city.name), \(city.countryCode)"),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]
    }
}
