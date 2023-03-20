//
//  WeatherDashboardCoordinator.swift
//  WeatherApp
//
//  Created by Pushpalatha Thotla on 3/17/23.
//

import Foundation
import UIKit

final public class WeatherCoordinator: Coordinator {
    public var children: [Coordinator] = []
    public var navigationController: UINavigationController
    private var networkManager: NetworkManaging
    
    public required init(_ navigationController: UINavigationController, networkManager: NetworkManaging) {
        self.navigationController = navigationController
        self.networkManager = networkManager
    }
    
    // load the story board
    public func start() {
        let storyboard = UIStoryboard(name: "WeatherDashboardViewController", bundle: nil)
        let controller = storyboard.instantiateViewController(
            identifier: "WeatherDashboardViewController",
            creator: { [weak self] coder in
                guard let self = self else { return UIViewController() }
                let dataManager = WeatherDashboardDataManager(network: self.networkManager)
                let viewModel = WeatherDashboardViewModel(dataManager: dataManager, cache: Cache())
                return WeatherDashboardViewController(viewModel, coder: coder)
            }
        )
        navigationController.pushViewController(controller, animated: false)
    }
}
