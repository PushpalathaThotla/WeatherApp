//
//  EnvironmentManaging.swift
//  WeatherApp
//
//  Created by Pushpalatha Thotla on 3/17/23.
//

import Foundation

public protocol EnvironmentManaging {
    typealias RequestHeaders = [String : String]
    var headers: RequestHeaders? { get }
    var baseUrl: String { get }
    var imageURL: String { get }
}
