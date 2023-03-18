//
//  Cache.swift
//  WeatherApp
//
//  Created by Pushpalatha Thotla on 3/17/23.
//

import Foundation

class Cache: Caching {
    
    private let cache = UserDefaults.standard
    
    func object(forKey key: String) -> Any? {
        return cache.object(forKey: key) as AnyObject
    }
    
    func setObject(_ obj: Any, forKey key: String) {
        cache.set(obj, forKey: key)
    }
}
