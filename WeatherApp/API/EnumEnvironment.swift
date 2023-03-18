//
//  EnumEnvironment.swift
//  WeatherApp
//
//  Created by Pushpalatha Thotla on 3/17/23.
//

import Foundation
enum EnumEnvironment: EnvironmentManaging {
    case development
    case prod
    
    var headers: RequestHeaders? { nil }
    
    var baseUrl: String {
        switch self {
        case .development:
            return "https://api.openweathermap.org/data/2.5/weather"
        case .prod:
            return "https://api.openweathermap.org/data/2.5/weather"
        }
    }
    
    var imageURL: String {
        switch self {
        case .development:
            return "https://openweathermap.org/img/wn/"
        case .prod:
            return "https://openweathermap.org/img/wn/"
        }
    }

}
