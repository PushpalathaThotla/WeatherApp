//
//  WeatherData.swift
//  WeatherApp
//
//  Created by Pushpalatha Thotla on 3/17/23.
//

import Foundation

struct WeatherData: Codable {
    let coord: Coordinate?
    let weather: [Weather]?
    let base: String?
    let main: Main?
    let visibility: Int?
    let wind: Wind?
    let rain: Rain?
    let clouds: Clouds?
    let dt: TimeInterval?
    let sys: Sys?
    let timezone: Int?
    let id: Int?
    let name: String?
    let cod: Int?
    
    struct Coordinate: Codable {
        let lon: Double?
        let lat: Double?
    }
    
    
    struct Weather: Codable {
        let id: Int?
        let main: String?
        let description: String?
        let icon: String?
    }

    struct Main: Codable {
        let temp: Double?
        let feelsLike: Double?
        let tempMin: Double?
        let tempMax: Double?
        let pressure: Int?
        let humidity: Int?
    }
    
    struct Wind: Codable {
        let speed: Double?
        let deg: Int?
        let gust: Double?
    }
    
    struct Rain: Codable {
        let oneHour: Double?
        
        enum CodingKeys: String, CodingKey {
            case oneHour = "h"
        }
    }
    
    struct Clouds: Codable {
        let all: Int?
    }

    struct Sys: Codable {
        let type: Int?
        let id: Int?
        let country: String?
        let sunrise: TimeInterval?
        let sunset: TimeInterval?
    }
}


