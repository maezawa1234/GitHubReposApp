import XCTest
@testable import GitHubReposApp

class UserDefaultsMock: UserDefaultsProtocol {
    func dictionary(forKey defaultName: String) -> [String : Any]? {
        return ["1": true, "2": false]
    }
    
    func string(forKey defaultName: String) -> String? {
        return nil
    }
    
    func set(_ value: Any?, forKey defaultName: String) {
    }
}
