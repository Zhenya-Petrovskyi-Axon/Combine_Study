//
//  TimedCache.swift
//  WeatherKit
//
//  Created by Ben Scheirman on 9/21/20.
//

import Foundation

public class TimedCache<Model: Codable> {
    private struct CacheEntry: Codable {
        let model: Model
        let expires: Date
    }
    private var cache: [String: CacheEntry] = [:]
    private let fileURL: URL
    
    public init(filename: String? = nil) {
        let file = filename ?? (String(describing: Model.self) + ".json")
        let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        fileURL = URL(fileURLWithPath: path).appending(path: file)
        loadIfNecessary()
    }
    
    public func set(cacheKey: String, model: Model, expires: Date) {
        print("Caching: \(cacheKey)")
        cache[cacheKey] = CacheEntry(model: model, expires: expires)
        save()
    }
    
    public func get(cacheKey: String) -> Model? {
        guard let entry = cache[cacheKey] else {
            return nil
        }
        
        if entry.expires < Date() {
            print("Cache item \(cacheKey) is expired.")
            cache[cacheKey] = nil
            return nil
        }
        
        print("Returning item \(cacheKey) from cache")
        return entry.model
    }
    
    private func loadIfNecessary() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let savedCache = try? JSONDecoder().decode([String: CacheEntry].self, from: data) {
            self.cache = savedCache.filter { $0.value.expires > Date() }
        }
    }
    
    private func save() {
        let data = try! JSONEncoder().encode(cache)
        try! data.write(to: fileURL)
    }
}
