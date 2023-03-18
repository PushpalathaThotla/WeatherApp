//
//  NetworkManaging.swift
//  WeatherApp
//
//  Created by Pushpalatha Thotla on 3/17/23.
//

import Foundation
import UIKit
import Combine

public enum Failure: Error {
    case badUrl, parsingError, statusCode, decoding
    case badResponse(_ errorDescription: String?)
    case other(Error)
    
    public static func map(_ error: Error) -> Failure {
      return (error as? Failure) ?? .other(error)
    }
}

public protocol NetworkManaging {
    typealias RequestParameters = [String : String]
    func execute<T: Decodable>(url: String, params: RequestParameters?) async throws -> T
    func getWeatherIconURL(for icon: String) -> URL?
}

public protocol Caching {
    func object(forKey key: String) -> Any?
    func setObject(_ obj: Any, forKey key: String)
}
