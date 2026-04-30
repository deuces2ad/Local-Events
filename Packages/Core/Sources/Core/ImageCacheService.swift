//
//  ImageCacheService.swift
//  Core
//
//  In-memory image cache using NSCache.
//

import UIKit

public actor ImageCacheService {

    public static let shared = ImageCacheService()

    private let cache = NSCache<NSString, UIImage>()
    private var runningTasks: [String: Task<UIImage?, Never>] = [:]

    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }

    public func image(for urlString: String) async -> UIImage? {
        let key = urlString as NSString

        // Return from cache if available
        if let cached = cache.object(forKey: key) {
            return cached
        }

        // Deduplicate in-flight requests
        if let existingTask = runningTasks[urlString] {
            return await existingTask.value
        }

        let task = Task<UIImage?, Never> { [cache] in
            guard let url = URL(string: urlString) else { return nil }
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let image = UIImage(data: data) else { return nil }
                cache.setObject(image, forKey: key, cost: data.count)
                return image
            } catch {
                return nil
            }
        }

        runningTasks[urlString] = task
        let result = await task.value
        runningTasks[urlString] = nil
        return result
    }

    public func clearCache() {
        cache.removeAllObjects()
    }
}
