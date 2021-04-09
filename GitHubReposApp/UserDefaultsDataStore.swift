import RxSwift
import RxCocoa

protocol UserDefaultsProtocol {
    func dictionary(forKey defaultName: String) -> [String : Any]?
    func string(forKey defaultName: String) -> String?
    func set(_ value: Any?, forKey defaultName: String)
}

extension UserDefaults: UserDefaultsProtocol {}

protocol DataStoreProtocol: AnyObject {
    // お気に入り情報を検索・保存する
    func fetch(ids: [Int]) -> Observable<[Int: Bool]>
    func save(liked: Bool, for id: Int) -> Observable<Bool>
    func allLikes() -> Observable<[Int: Bool]>
}

final class UserDefaultsDataStore: DataStoreProtocol {
    let userDefaults: UserDefaultsProtocol
    
    init(userDefaults: UserDefaultsProtocol) {
        self.userDefaults = userDefaults
    }
    
    // MARK: お気に入りの管理
    func fetch(ids: [Int]) -> Observable<[Int: Bool]> {
        return Observable.create { [weak self] observer in
            let all = self?._allLikes()
            let result = all?.filter { (k, v) -> Bool in
                ids.contains{ $0 == k }
            }
            if let result = result {
                observer.onNext(result)
                observer.onCompleted()
            } else {
                print("favorite list is empty")
                observer.onNext([:])
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func save(liked: Bool, for id: Int) -> Observable<Bool> {
        return Observable.create { observer in
            
            var all = self._allLikes()
            all[id] = liked
            let pairs = all.map { (k, v) in (k, v) }
            let newAll = Dictionary(uniqueKeysWithValues: pairs)
            self.userDefaults.set(newAll, forKey: "likes")
            observer.onNext(liked)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func allLikes() -> Observable<[Int: Bool]> {
        return .just(_allLikes())
    }
    
    private func _allLikes() -> [Int: Bool] {
        if let dictionary = userDefaults.dictionary(forKey: "likes") as? [String: Bool] {
            let pair = dictionary.map { (k, v) in (Int(k)!, v) }
            let likes = Dictionary(uniqueKeysWithValues: pair)
            return likes
        } else {
            return [:]
        }
    }
}

