//
//  WeatherDashboardViewModel.swift
//  WeatherApp
//
//  Created by Pushpalatha Thotla on 3/17/23.
//

import Foundation
import CoreLocation
import UIKit

class WeatherDashboardViewModel: ObservableObject {
    
    struct Constant {
        static let lastSearchKey = "location"
    }
    
    enum State {
        case none
        case loading
        case ready
        case error(_ messgae: String)
    }

    private var dataSource: WeatherData?
    private let cache: Caching
    private let dataManager: WeatherDashboardDataManaging
    private var params: [String : String] = ["appid" : "e9b75aa00c3ce6bf64482d4ef18f1096", "units":"metric"]
    
    @Published var viewState: State = .none
    
    required init(dataManager: WeatherDashboardDataManaging, cache: Caching) {
        self.cache = cache
        self.dataManager = dataManager
    }

    lazy var title: String = {
       "Weather"
    }()
}

extension WeatherDashboardViewModel {
    func lastSearch() -> (valid: Bool, location: String?) {
        if let found = cache.object(forKey: Constant.lastSearchKey) as? String {
            return (true, found)
        }
        return (false, nil)
    }
}

extension WeatherDashboardViewModel {
        
    func fetchWeather(for location: String)   {
        if location.isEmpty { return }
        viewState = .loading
        cache.setObject(location, forKey: Constant.lastSearchKey)
        CLGeocoder().geocodeAddressString(location) { (placemarks, error) in
            if let places = placemarks,
                let place = places.first,
                let coord =  place.location?.coordinate {
                self.fetchWeather(coord: coord)
            } else {
                self.viewState = .ready
                if let error = error {
                    self.viewState = .error(error.localizedDescription)
                }
            }
        }
    }
    
    private func fetchWeather(coord: CLLocationCoordinate2D) {
        Task {
            try await fetchWeatherFor(latitude:coord.latitude, longitude: coord.longitude)
        }
    }

    func fetchWeatherFor(latitude: Double, longitude: Double) async throws  {
        viewState = .loading
        params["lat"] = "\(latitude)"
        params["lon"] = "\(longitude)"
        dataSource = try await dataManager.fetchWeatherData(with: params)
        viewState = .ready
    }
}

extension WeatherDashboardViewModel {
    
    var place: String? {
        dataSource?.name
    }
    
    var windSpeedTitle: String? {
        "Wind Speed"
    }

    var humidityTitle: String? {
        "Humidity"
    }

    var feelsLikeTitle: String? {
        "Feels like"
    }
    
    var humidity: String? {
        if let found = dataSource?.main?.humidity {
            return String(format: "%d%%", found)
        }
        return nil
    }
    
    var pressure: String? {
        if let found = dataSource?.main?.pressure {
            return "Pressure: \(found)"
        }
        return nil
    }
    
    var temperatureDescription: String? {
        if let found = dataSource?.weather?.first?.description {
            return found
        }
        return nil
    }
    
    var temperature: NSMutableAttributedString? {
        if let found = dataSource?.main?.temp {
            let attrString = NSMutableAttributedString(string: getTempFor(found),
                                                                     attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 36)])
            attrString.append(NSMutableAttributedString(string:"°",
                                                                attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18),.baselineOffset: NSNumber(value: 18)]))
            return attrString
        }
        return nil
    }
    
    var tempratureMin: NSMutableAttributedString? {
        if let found = dataSource?.main?.tempMin {
            let highTempStr = "L : " + getTempFor(found)
            let attrString = NSMutableAttributedString(string: highTempStr,
                                                                     attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25)])

            attrString.append(NSMutableAttributedString(string:"°",
                                                                attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18),.baselineOffset: NSNumber(value: 12)]))
            return attrString

        }
        return nil
    }
    
    var temperatureMax: NSMutableAttributedString? {
        if let found = dataSource?.main?.tempMax {
            let highTempStr = "H : " + getTempFor(found)
            let attrString = NSMutableAttributedString(string: highTempStr,
                                                                     attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25)])

            attrString.append(NSMutableAttributedString(string:"°",
                                                                attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18),.baselineOffset: NSNumber(value: 12)]))
            return attrString
        }
        return nil
    }
    
    var feelsLike: NSMutableAttributedString? {
        if let found = dataSource?.main?.feelsLike {
                let attrString = NSMutableAttributedString(string: getTempFor(found),
                                                                         attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)])

                attrString.append(NSMutableAttributedString(string:"°",
                                                                    attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 8),.baselineOffset: NSNumber(value: 12)]))
                return attrString
        }
        return nil
    }

    var weatherImageURL: URL? {
        if let found = dataSource?.weather?.first?.icon {
            return dataManager.getWeatherIconURL(for: found)
        }
        return nil
    }
    
   private func getTempFor(_ temp: Double) -> String {
        return String(format: "%1.0f", temp)
    }

    var windSpeed: String? {
        if let found = dataSource?.wind?.speed {
            return String(format: "%0.1f",found )
        }
        return nil
    }

    var hasWeatherData: Bool {
        return (dataSource != nil)
    }
}
