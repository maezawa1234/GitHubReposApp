struct SearchResponse<Item: Decodable>: Decodable {
    let totalCount: Int
    let items: [Item]
    
    enum CodingKeys : String, CodingKey {
        case totalCount = "total_count"
        case items
    }
}

struct RepositoriesResponse {
    let repositories: [Repository]
}

extension RepositoriesResponse: Decodable {
    init(from decoder: Decoder) throws {
        var repositories: [Repository] = []
        var unkeyedContainer = try decoder.unkeyedContainer()
        while !unkeyedContainer.isAtEnd {
            let repository = try unkeyedContainer.decode(Repository.self)
            repositories.append(repository)
        }
        self.init(repositories: repositories)
    }
}

