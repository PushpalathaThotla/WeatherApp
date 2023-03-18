//
//  WeatherDashboardViewController.swift
//  WeatherApp
//
//  Created by Pushpalatha Thotla on 3/17/23.
//

import Foundation
import UIKit
import Combine
import CoreLocation

class WeatherDashboardViewController: UIViewController  {
    
    private let locationManager = CLLocationManager()
    
    private var viewModel: WeatherDashboardViewModel
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var weatherImageView: UIImageView!
    @IBOutlet var placeLabel: UILabel!
    @IBOutlet var currentTemparatureLabel: UILabel!
    @IBOutlet var currentTemparatureDescriptionLabel: UILabel!
    @IBOutlet var highTemparatureLabel: UILabel!
    @IBOutlet var lowTemparatureLabel: UILabel!
    
    @IBOutlet var windSpeedTitleLabel: UILabel!
    @IBOutlet var windSpeedValueLabel: UILabel!
    
    @IBOutlet var humidityTitleLabel: UILabel!
    @IBOutlet var humidityValueLabel: UILabel!
    
    @IBOutlet var feelsLikeTitleLabel: UILabel!
    @IBOutlet var feelsLikeValueLabel: UILabel!
    
    init?(_ viewModel: WeatherDashboardViewModel, coder: NSCoder) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    @available(*, unavailable, renamed: "init(viewModel:coder:)")
    required init?(coder: NSCoder) {
        fatalError("Invalid way of decoding this class")
    }
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .red
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        indicator.center = view.center
        view.addSubview(indicator)
        return indicator
    }()
    
    private var cancellables: Set = Set<AnyCancellable>()
    private var searchWorkItem: DispatchWorkItem?
    
    private func configureLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        configureLocation()
        addObservers()
        var searchkey = "Chicago"
        if viewModel.lastSearch().valid {
            searchkey = viewModel.lastSearch().location ?? ""
        }
        performSearch(text: searchkey)
        
    }
    
    private func addObservers() {
        viewModel.$viewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state  in
                guard let self = self else { return }
                switch state {
                case .loading:
                    self.activityIndicator.startAnimating()
                case .ready:
                    self.activityIndicator.stopAnimating()
                    self.updateUI()
                case .error(let message):
                    self.activityIndicator.stopAnimating()
                    print("Error with \(message)")
                    //                    let controller = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                    //                    self.present(controller, animated: true)
                }
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(text: String) {
        // Perform API call here
        print("Performing search...")
        Task {
            viewModel.fetchWeather(for: text)
            //            do {
            //                try await viewModel.fetchWeather(for: text)
            //            } catch (let error) {
            //                print("Weather Error with \(error)")
            //                viewModel.viewState = .error(error.localizedDescription)
            //            }
        }
    }
    
    private func updateUI() {
        placeLabel.text = viewModel.place
        currentTemparatureLabel.attributedText = viewModel.temperature
        currentTemparatureDescriptionLabel.text = viewModel.temperatureDescription
        highTemparatureLabel.attributedText = viewModel.temperatureMax
        lowTemparatureLabel.attributedText = viewModel.tempratureMin
        if let url  = viewModel.weatherImageURL {
            weatherImageView.load(url: url)
        } else {
            weatherImageView.image = nil
        }
        windSpeedTitleLabel.text = viewModel.windSpeedTitle
        windSpeedValueLabel.text = viewModel.windSpeed
        humidityTitleLabel.text = viewModel.humidityTitle
        humidityValueLabel.text = viewModel.humidity
        feelsLikeTitleLabel.text = viewModel.feelsLikeTitle
        feelsLikeValueLabel.attributedText = viewModel.feelsLike
    }
}

extension WeatherDashboardViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchWorkItem?.cancel()
        searchWorkItem = DispatchWorkItem { [weak self] in
            self?.performSearch(text: searchText)
        }
        guard let searchWorkItem = searchWorkItem else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: searchWorkItem)
    }
}


extension WeatherDashboardViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        print("Latitude: \(latitude), Longitude: \(longitude)")
        
        locationManager.stopUpdatingLocation()
        
        Task {
            try await viewModel.fetchWeatherFor(latitude: latitude, longitude: longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}
