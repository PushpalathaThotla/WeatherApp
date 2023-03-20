//
//  WeatherDashboardViewModelTests.swift
//  WeatherAppTests
//
//  Created by Pushpalatha Thotla on 3/18/23.
//

import Foundation
import XCTest
@testable import WeatherApp

extension Bundle {
    static var current: Bundle {
        class __ { }
        return Bundle(for: __.self)
    }
}


class MockNetworkManager: NetworkManaging {
    func getWeatherIconURL(for icon: String) -> URL? {
        return URL(string: "https://openweathermap.org/img/wn/10d@2x.png")
    }
    
    func execute<T>(url: String, params: RequestParameters?) async throws -> T where T : Decodable {
        let model: T = try await withCheckedThrowingContinuation( { continuation in
            let decoder = JSONDecoder()
                guard let url = Bundle.main.url(forResource: "WeatherDashboard", withExtension: "json"),
                   let data = try? Data(contentsOf: url),
                      let decodedResponse = try? decoder.decode(T.self, from: data) else {
                    continuation.resume(throwing: Failure.parsingError)
                    return
                }
                print("Response from asyn await \(decodedResponse)")
                continuation.resume(returning: decodedResponse)
        })
        return model
    }
}

class MockWeatherDataManager: WeatherDashboardDataManaging {
    
    private let networkManager: NetworkManaging
    
    init(_ networkManger: NetworkManaging) {
        self.networkManager = networkManger
    }
    
    func fetchWeatherData(with params: [String : String]) async throws -> WeatherData {
        return try await networkManager.execute(url: "WeatherDashboard", params: nil)
    }
    
    func getWeatherIconURL(for icon: String) -> URL? {
        networkManager.getWeatherIconURL(for: icon)
    }
}

class MockCache: Caching {
    func object(forKey key: String) -> Any? { nil }
    func setObject(_ obj: Any, forKey key: String) { }
}

final class WeatherDashboardViewModelTests: XCTestCase {
    
    var viewModel: WeatherDashboardViewModel!

    override func setUpWithError() throws {
        let dataManager = MockWeatherDataManager(MockNetworkManager())
        viewModel = WeatherDashboardViewModel(dataManager: dataManager, cache: MockCache())
        Task {
            try await viewModel.fetchWeatherFor(latitude: 37.90145, longitude: -122.061776)
        }
    }

    override func tearDownWithError() throws {
        viewModel = nil
    }
    
    func testViewData() {
        // fetchWeatherFor async call , this test is called before the JSON data response parsing. Just adding delay
        let  searchWorkItem = DispatchWorkItem {
            print("testTitle")
            XCTAssertEqual(self.viewModel.title, "Weather")
            XCTAssertEqual(self.viewModel.hasWeatherData, true)
            XCTAssertEqual(self.viewModel.place, "Chicago")
            XCTAssertEqual(self.viewModel.place, "light rain")
            XCTAssertEqual(self.viewModel.weatherImageURL,URL(string:"https://openweathermap.org/img/wn/10d@2x.png"))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: searchWorkItem)
    }
}
