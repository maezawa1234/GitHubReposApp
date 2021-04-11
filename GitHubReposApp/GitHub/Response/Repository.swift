struct Repository: Codable {
    let id: Int
    let name: String
    let fullName: String
    let description: String?
    let language: String?
    let stargazersCount: Int
    let owner: User
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case language
        case fullName = "full_name"
        case owner
        case stargazersCount = "stargazers_count"
    }
}

extension Repository: Equatable {
    static func == (lhs: Repository, rhs: Repository) -> Bool {
        return lhs.id == rhs.id
    }
}





