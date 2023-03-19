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
    // IBOutlets
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
    
    private let locationManager = CLLocationManager()
    private var viewModel: WeatherDashboardViewModel

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .red
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        indicator.center = view.center
        view.addSubview(indicator)
        return indicator
    }()

    init?(_ viewModel: WeatherDashboardViewModel, coder: NSCoder) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    @available(*, unavailable, renamed: "init(viewModel:coder:)")
    required init?(coder: NSCoder) {
        fatalError("Invalid way of decoding this class")
    }
    
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
        addObservers()
        
        // if we have last search text , then start weather search with the last search text
        if viewModel.lastSearch().valid {
            if let  searchkey = viewModel.lastSearch().location {
                performSearch(text: searchkey)
            }
        } else {
            /* Else its first time the app is opened so call the location services
             and search for the current latitude and longitude values ,
             if the user provides the permission */
            configureLocation()
        }
    }
    
    private func addObservers() {
        viewModel.$viewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state  in
                guard let self = self else { return }
                switch state {
                case .none:
                    self.activityIndicator.stopAnimating()
                case .loading:
                    self.activityIndicator.startAnimating()
                case .ready:
                    self.activityIndicator.stopAnimating()
                    self.updateUI()
                case .error(let message):
                    self.activityIndicator.stopAnimating()
                    print("Error with \(message)")
                    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                    self.present(alert, animated: true)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                }
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(text: String) {
        // Perform API call here
        print("Performing search...")
        Task {
            viewModel.fetchWeather(for: text)
        }
    }
    
    private func updateUI() {
        // update the UI only if the data is available
        if viewModel.hasWeatherData == false { return }
        
        placeLabel.text = viewModel.place
        currentTemparatureLabel.attributedText = viewModel.temperature
        currentTemparatureDescriptionLabel.text = viewModel.temperatureDescription
        highTemparatureLabel.attributedText = viewModel.temperatureMax
        lowTemparatureLabel.attributedText = viewModel.tempratureMin
        windSpeedTitleLabel.text = viewModel.windSpeedTitle
        windSpeedValueLabel.text = viewModel.windSpeed
        humidityTitleLabel.text = viewModel.humidityTitle
        humidityValueLabel.text = viewModel.humidity
        feelsLikeTitleLabel.text = viewModel.feelsLikeTitle
        feelsLikeValueLabel.attributedText = viewModel.feelsLike
        
        // Image is caching is applied here .
        weatherImageView.image = nil
        if let url  = viewModel.weatherImageURL {
            weatherImageView.load(url: url)
        }
    }
}

extension WeatherDashboardViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchWorkItem?.cancel()
        //  encapsulates work to be performed on a dispatch queue
        searchWorkItem = DispatchWorkItem { [weak self] in
            self?.performSearch(text: searchText)
        }
        guard let searchWorkItem = searchWorkItem else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: searchWorkItem)
    }
}


extension WeatherDashboardViewController: CLLocationManagerDelegate {
    // Invoked when the authorization status changes for this application
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
    
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        print("Latitude: \(latitude), Longitude: \(longitude)")
        locationManager.stopUpdatingLocation()
        // perform search based on current location.
        Task {
            try await viewModel.fetchWeatherFor(latitude: latitude, longitude: longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}
