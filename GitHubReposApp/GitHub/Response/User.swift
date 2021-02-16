import RxDataSources

struct User : Decodable {
    let id: Int
    let login: String
    let avatarURL: URL
    //let name: String
    
    private enum CodingKeys: String, CodingKey {
        case login, id
        case avatarURL = "avatar_url"
    }
}

