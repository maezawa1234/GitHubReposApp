import Foundation

protocol UserDefaultsProtocol {
    func dictionary(forKey defaultName: String) -> [String : Any]?
    func string(forKey defaultName: String) -> String?
    
    func set(_ value: Any?, forKey defaultName: String)
}

extension UserDefaults: UserDefaultsProtocol {}

protocol DataStoreProtocol: AnyObject {
    // お気に入り情報を検索・保存する
    func fetch(ids: [Int],
               completion: @escaping (Result<[Int: Bool]>) -> Void)
    func save(liked: Bool,
              for id: Int,
              completion: @escaping (Result<Bool>) -> Void)
    func allLikes(completion: @escaping (Result<[Int: Bool]>) -> Void)
}

final class UserDefaultsDataStore: DataStoreProtocol {
    
    let userDefaults: UserDefaultsProtocol
    
    init(userDefaults: UserDefaultsProtocol) {
        self.userDefaults = userDefaults
    }
    
    // MARK: お気に入りの管理
    func fetch(ids: [Int],
               completion: @escaping (Result<[Int: Bool]>) -> Void) {
        let all = allLikes()
        let result = all.filter { (k, v) -> Bool in
            ids.contains{ $0 == k }
        }
        completion(.success(result))
    }
    
    func save(liked: Bool, for id: Int,
              completion: @escaping (Result<Bool>) -> Void) {
        var all = allLikes()
        all[id] = liked
        let pairs = all.map { (k, v) in (k, v) }
        let newAll = Dictionary(uniqueKeysWithValues: pairs)
        userDefaults.set(newAll, forKey: "likes")
        completion(.success(liked))
    }
    
    func allLikes(completion: @escaping (Result<[Int: Bool]>) -> Void) {
        completion(.success(allLikes()))
    }
    
    private func allLikes() -> [Int: Bool] {
        if let dictionary = userDefaults.dictionary(forKey: "likes") as? [String: Bool] {
            let pair = dictionary.map { (k, v) in (Int(k)!, v) }
            let likes = Dictionary(uniqueKeysWithValues: pair)
            return likes
        } else {
            return [:]
        }
    }
}

