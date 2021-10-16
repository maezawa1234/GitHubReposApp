//
//  Cache.swift
//  GitHubReposApp
//
//  Created by 前澤健一 on 2021/06/29.
//

import Foundation
import UIKit

protocol CacheProtocol {
    associatedtype Value: AnyObject
    func object(forKey key: AnyObject) -> Value?
    func setObject(_ object: Value, forKey key: AnyObject)
}

final class ImageCache: CacheProtocol {
    
    // MARK: - Singleton
    static let shared = ImageCache()
    private init() {}
    
    private let cache = NSCache<AnyObject, AnyObject>()
    
    func object(forKey key: AnyObject) -> UIImage? {
        return cache.object(forKey: key) as? UIImage
    }
    
    func setObject(_ object: UIImage, forKey key: AnyObject) {
        cache.setObject(object, forKey: key)
    }
}
