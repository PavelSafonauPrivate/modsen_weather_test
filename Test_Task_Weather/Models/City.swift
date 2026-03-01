//
//  City.swift
//  Test_Task_Weather
//
//  Created by developer on 27.02.26.
//

struct City {
    let name: String
    let countryCode: String
}

struct CityFactory {
    static func defaultCities() -> [City] {
        [City(name: "London", countryCode: "GB"),
         City(name: "Paris", countryCode: "FR"),
         City(name: "New York", countryCode: "US"),
         City(name: "Rome", countryCode: "IT"),
         City(name: "Moscow", countryCode: "RU")]
    }
}
