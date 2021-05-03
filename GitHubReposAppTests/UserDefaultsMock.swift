import XCTest
@testable import GitHubReposApp

class UserDefaultsMock: UserDefaultsProtocol {
    private var saveSpace: [String: [String: Any]] = [:]
    
    func dictionary(forKey defaultName: String) -> [String : Any]? {
        return ["1": true, "2": false, "3": true]
    }
    
    func string(forKey defaultName: String) -> String? {
        return nil
    }
    
    func set(_ value: Any?, forKey defaultName: String) {
        guard let value = value else {
            return
        }
        guard let _value = value as? [String: Any] else {
            return
        }
        saveSpace[defaultName] = _value
    }
}
