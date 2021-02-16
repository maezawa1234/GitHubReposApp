struct Repository: Decodable {
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





