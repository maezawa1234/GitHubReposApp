import Foundation

struct User : Codable {
    let id: Int
    let login: String
    let avatarURL: URL
    let name: String?
    
    private enum CodingKeys: String, CodingKey {
        case login, id
        case avatarURL = "avatar_url"
        case name
    }
    
    init() {
        self.id = -1
        self.login = ""
        self.avatarURL = URL(fileURLWithPath: "")
        self.name = nil
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return rhs.id == rhs.id
    }
}

