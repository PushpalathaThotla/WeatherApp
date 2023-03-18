//
//  WeatherDashboardDataManager.swift
//  WeatherApp
//
//  Created by Pushpalatha Thotla on 3/17/23.
//

import Foundation

//e9b75aa00c3ce6bf64482d4ef18f1096
//https://api.openweathermap.org/data/2.5/weather?q=chicago&appid=e9b75aa00c3ce6bf64482d4ef18f1096

protocol WeatherDashboardDataManaging {
    func fetchWeatherData(with params: [String : String]) async throws -> WeatherData
    func getWeatherIconURL(for icon: String) -> URL?
}

struct WeatherDashboardDataManager: WeatherDashboardDataManaging {
 
    private let network: NetworkManaging
    
    init(network: NetworkManaging) {
        self.network = network
    }
    
    func fetchWeatherData(with params: [String : String]) async throws -> WeatherData {
        try await network.execute(url: "", params: params)
    }

    func getWeatherIconURL(for icon: String) -> URL? {
        network.getWeatherIconURL(for: icon)
    }
}
