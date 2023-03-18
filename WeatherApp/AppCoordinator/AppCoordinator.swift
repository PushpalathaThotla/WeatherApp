//
//  AppCoordinator.swift
//  WeatherApp
//
//  Created by Pushpalatha Thotla on 3/17/23.
//

import Foundation
import UIKit

final class AppCoordinator: Coordinator {
    internal var children: [Coordinator] = []
    internal var navigationController: UINavigationController
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let network: NetworkManaging = NetworkManager(EnumEnvironment.prod)
        let coordinator = WeatherCoordinator(navigationController, networkManager: network)
        children.append(coordinator)
        coordinator.start()
    }
    
    func childDidFinish(_ child: Coordinator?) {
        if let index = children.firstIndex(where: { $0 === child }) {
            children.remove(at: index)
        }
    }
}
