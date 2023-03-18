//
//  Coordinator.swift
//  WeatherApp
//
//  Created by Pushpalatha Thotla on 3/17/23.
//

import UIKit

public protocol Coordinator: AnyObject {
    var children: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    func start()
}
