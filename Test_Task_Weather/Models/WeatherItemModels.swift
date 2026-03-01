//
//  WeatherItemModels.swift
//  Test_Task_Weather
//
//  Created by developer on 27.02.26.
//

struct CurrentWeatherItem {
    let city: String
    let temperatureCelsius: Double
}

struct ForecastItem: Hashable {
    let date: Date
    let temperatureCelsius: Double
    let humidityPercent: Int
    let pressureHPa: Int
    let cloudsPercent: Int
    let visibility: Int
}
