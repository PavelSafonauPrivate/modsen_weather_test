//
//  WeatherDetailRow.swift
//  Test_Task_Weather
//
//  Created by developer on 27.02.26.
//

import Foundation

struct DaySection {
    let date: Date
    let title: String
    let items: [ForecastItem]
}

@MainActor
final class WeatherDetailViewModel {
    let title: String

    private let city: String
    private let weatherService: WeatherServiceProtocol

    private(set) var sections: [DaySection] = []
    var onChange: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?

    init(city: String, weatherService: WeatherServiceProtocol) {
        self.city = city
        self.weatherService = weatherService
        title = city
    }

    func load() {
        onLoadingStateChanged?(true)
        Task {
            defer { onLoadingStateChanged?(false) }
            do {
                let items = try await weatherService.fetchForecast(city: city)
                sections = formattedItems(items)
                onChange?()
            } catch {
                onError?("Failed to load forecast: \(error.localizedDescription)")
            }
        }
    }

    private func formattedItems(_ items: [ForecastItem]) -> [DaySection] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: items) { item in
            calendar.startOfDay(for: item.date)
        }

        return grouped.keys.sorted().compactMap { day in
            guard let dayItems = grouped[day] else { return nil }
            return DaySection(date: day,
                              title: day.formatted(.dateTime.year().month().day().weekday()),
                              items: dayItems.sorted { $0.date < $1.date })
        }
    }
}
