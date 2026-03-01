//
//  Test_Task_WeatherUITests.swift
//  Test_Task_WeatherUITests
//
//  Created by developer on 27.02.26.
//

import XCTest

@MainActor
final class Test_Task_WeatherUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testShowCitiesScreen() throws {
        XCTAssertTrue(app.navigationBars["Cities"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.tables["cityList.table"].exists)
        XCTAssertTrue(app.cells["cityCell.London"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.cells["cityCell.Moscow"].waitForExistence(timeout: 2))
    }

    func testOpenWeatherForecastScreen() throws {
        let londonCell = app.cells["cityCell.London"]
        XCTAssertTrue(londonCell.waitForExistence(timeout: 2))
        londonCell.tap()

        XCTAssertTrue(app.navigationBars["London"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.collectionViews.element.waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Temperature:'")).firstMatch.exists)
    }

    func testShowUpdateButton() throws {
        let londonCell = app.cells["cityCell.London"]
        XCTAssertTrue(londonCell.waitForExistence(timeout: 2))
        londonCell.swipeLeft()
        XCTAssertTrue(app.buttons["Update"].waitForExistence(timeout: 2))
    }
}
