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
            guard let url = Bundle.current.url(forResource: url, withExtension: "json") else {
                continuation.resume(throwing: Failure.badUrl)
                return
            }
            let request = URLRequest(url: url)
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(for: request, delegate: nil)
                    guard let decodedResponse = try? JSONDecoder().decode(T.self, from: data) else {
                        continuation.resume(throwing: Failure.parsingError)
                        return
                    }
                    print("Response from asyn await \(decodedResponse)")
                    continuation.resume(returning: decodedResponse)
                } catch {
                    continuation.resume(throwing: Failure.badResponse("error?.localizedDescription"))
                }
            }
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
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        viewModel = nil
    }
    
    func testTitle() {
        XCTAssertEqual(viewModel.title, "Weather")
    }
}
