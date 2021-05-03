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
    func fetch(ids: [Int]) -> Single<[Int: Bool]>
    func save(isFavorite: Bool, for id: Int) -> Single<Bool>
    func allLikes() -> Single<[Int: Bool]>
    // リポジトリ情報を保存・取得する
    func save(repos: [Repository]) -> Single<[Repository]>
    func fetch(using ids: [Int]) -> Single<[Repository]>
}

final class UserDefaultsDataStore: DataStoreProtocol {
    static let shared = UserDefaultsDataStore(userDefaults: UserDefaults.standard)
    private init(userDefaults: UserDefaultsProtocol) {
        self.userDefaults = userDefaults
    }
    
    private let userDefaults: UserDefaultsProtocol
    
    // MARK: お気に入りの管理
    func fetch(ids: [Int]) -> Single<[Int: Bool]> {
        return Single.create { [weak self] observer in
            
            let disposables = Disposables.create()
            guard let strongSelf = self else {
                observer(.success([:]))
                return disposables
            }
            let all = strongSelf._allLikes()
            let result = all.filter { (k, v) -> Bool in
                ids.contains { $0 == Int(k) }
            }
            
            let _result = result.map { (str, v) in (Int(str)!, v) }
            let a = Dictionary(uniqueKeysWithValues: _result)
            observer(.success(a))
            
            return disposables
        }
    }
    
    func save(isFavorite: Bool, for id: Int) -> Single<Bool> {
        return Single.create { observer in
            print("will save with liked:", isFavorite)
            var all = self._allLikes()
            let id = String(id)
            all[id] = isFavorite
            let pairs = all.map { (k, v) in (k, v) }
            let newAll = Dictionary(uniqueKeysWithValues: pairs)
            self.userDefaults.set(newAll, forKey: "likes")
            observer(.success(isFavorite))
            
            return Disposables.create()
        }
    }
    
    func allLikes() -> Single<[Int: Bool]> {
        let pair = _allLikes().map { (k, v) in (Int(k)!, v) }
        let likes = Dictionary(uniqueKeysWithValues: pair)
        return .just(likes)
    }
    
    private func _allLikes() -> [String: Bool] {
        guard let dictionary = userDefaults.dictionary(forKey: "likes") as? [String: Bool] else {
            return [:]
        }
        let pair = dictionary.map { (k, v) in (k, v) }
        let likes = Dictionary(uniqueKeysWithValues: pair)
        return likes
    }
    // リポジトリ情報の保存・取得
    func save(repos: [Repository]) -> Single<[Repository]> {
        return Single.create { observer in
            
            do {
                try repos.forEach { repo in
                    let encoder = JSONEncoder()
                    let data = try encoder.encode(repo)
                    let jsonString = String(data: data, encoding: .utf8)
                    self.userDefaults.set(jsonString, forKey: String(repo.id))
                }
                observer(.success(repos))
            } catch {
                print("error occured: saving repositories \(error.localizedDescription)")
                observer(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    func fetch(using ids: [Int]) -> Single<[Repository]> {
        return Single.create { observer in
            
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
                observer(.success(result))
            } catch {
                print("error occured: fetching repositories \(error.localizedDescription)")
                observer(.error(error))
            }
            return Disposables.create()
            
        }
    }
}

