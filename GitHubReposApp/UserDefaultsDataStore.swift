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
    // リポジトリ情報を保存・取得する
    func save(repos: [Repository]) -> Observable<[Repository]>
    func fetch(using ids: [Int]) -> Observable<[Repository]>
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
                ids.contains{ $0 == Int(k) }
            }
            
            if let result = result {
                let _result = result.map { (str, v) in (Int(str)!, v) }
                let a = Dictionary(uniqueKeysWithValues: _result)
                observer.onNext(a)
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
            print("will save with liked:", liked)
            var all = self._allLikes()
            let id = String(id)
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
        let pair = _allLikes().map { (k, v) in (Int(k)!, v) }
        let likes = Dictionary(uniqueKeysWithValues: pair)
        print("allLikes: ", likes)
        return .just(likes)
    }
    
    private func _allLikes() -> [String: Bool] {
        if let dictionary = userDefaults.dictionary(forKey: "likes") as? [String: Bool] {
            let pair = dictionary.map { (k, v) in (k, v) }
            let likes = Dictionary(uniqueKeysWithValues: pair)
            return likes
        } else {
            return [:]
        }
    }
    // リポジトリ情報の保存・取得
    func save(repos: [Repository]) -> Observable<[Repository]> {
        return Observable.create { observer in
            
            do {
                try repos.forEach { repo in
                    let encoder = JSONEncoder()
                    let data = try encoder.encode(repo)
                    let jsonString = String(data: data, encoding: .utf8)
                    self.userDefaults.set(jsonString, forKey: String(repo.id))
                }
                observer.onNext(repos)
                observer.onCompleted()
            } catch {
                print("GGGGGGGGGGGGGGGGGGGGGGGGGGGG")
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
    
    func fetch(using ids: [Int]) -> Observable<[Repository]> {
        return Observable.create { observer in
            
            let decoder = JSONDecoder()
            do {
                var result = [Repository]()
                for id in ids {
                    if let jsonString = self.userDefaults.string(forKey: String(id)),
                       let data = jsonString.data(using: .utf8) {
                        let repo: Repository = try decoder.decode(Repository.self, from: data)
                        result.append(repo)
                    }
                }
                observer.onNext(result)
                observer.onCompleted()
            } catch {
                print("TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT")
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
}

