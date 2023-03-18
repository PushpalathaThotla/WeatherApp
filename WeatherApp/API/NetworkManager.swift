//
//  NetworkManager.swift
//  WeatherApp
//
//  Created by Pushpalatha Thotla on 3/17/23.
//

import Foundation
class NetworkManager: NetworkManaging {
    
    private let environment: EnvironmentManaging

    public required init(_ environment: EnvironmentManaging) {
        self.environment = environment
    }

    // Asyn Await comatible api
    func execute<T: Decodable>(url: String, params: RequestParameters?) async throws -> T {
        
        let model: T = try await withCheckedThrowingContinuation( { continuation in
            
            @Sendable func decode(data: Data) {
                if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) {
                    print("Weather: Respons json  \(jsonObject)")
                }
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                guard let decodedResponse = try? decoder.decode(T.self, from: data) else {
                    continuation.resume(throwing: Failure.parsingError)
                    return
                }
                continuation.resume(returning: decodedResponse)
            }
            
            var urlComponents = URLComponents(string: environment.baseUrl + url)
            if let _params = params {
                urlComponents?.queryItems = _params.map {
                     URLQueryItem(name: $0, value: $1)
                }
            }
            
            guard let url = urlComponents?.url else {
                continuation.resume(throwing: Failure.badUrl)
                return
            }
            
            let request = URLRequest(url: url)
            print("Weather: Requesting data for \(request.url?.absoluteString ?? "")")
            Task {
                do {
                    let (data, response) = try await URLSession.shared.data(for: request, delegate: nil)
                    guard let response = response as? HTTPURLResponse else {
                        continuation.resume(throwing: Failure.badResponse("error?.localizedDescription"))
                        return
                    }
                    switch response.statusCode {
                    case 200...299:
                        
                        decode(data: data)
                    case 401:
                        continuation.resume(throwing: Failure.badResponse("error?.localizedDescription"))
                    default:
                        continuation.resume(throwing: Failure.badResponse("error?.localizedDescription"))
                    }
                } catch {
                    continuation.resume(throwing: Failure.badResponse("error?.localizedDescription"))
                }
            }
        })
        return model
    }
    
    func getWeatherIconURL(for icon: String) -> URL? {
       return URL(string: environment.imageURL + icon + "@2x.png")
    }
}
