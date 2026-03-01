//
//  WeatherServiceError.swift
//  Test_Task_Weather
//
//  Created by developer on 27.02.26.
//

enum WeatherServiceError: Error {
    case cityNotFound
    case invalidURL
    case invalidJSON
    case parseFailed
}
