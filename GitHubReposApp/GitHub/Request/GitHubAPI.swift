import Foundation

final class GitHubAPI {
    struct SearchRepositoriesRequest: GitHubRequest {
        let keyword: String
        // GitHubRequestが要求する連想型
        typealias Response = SearchResponse<Repository>
        
        var method: HTTPMethod {
            return .get
        }
        var path: String {
            return "/search/repositories"
        }
        var queryItems: [URLQueryItem] {
            return [URLQueryItem(name: "q", value: keyword)]
        }
    }
    
    struct SearchUsersRequest: GitHubRequest {
        typealias Response = SearchResponse<User>
        
        let keyword: String
        
        var method: HTTPMethod {
            return .get
        }
        var path: String {
            return "/search/users"
        }
        var queryItems: [URLQueryItem] {
            return [URLQueryItem(name: "q", value: keyword)]
        }
    }
    
    struct UserRepositoriesRequest: GitHubRequest {
        typealias Response = RepositoriesResponse
        
        let userName: String
        
        var method: HTTPMethod {
            return .get
        }
        var path: String {
            return "/users/\(userName)/repos"
        }
        
        var queryItems: [URLQueryItem] {
            return []
        }
    }
    
    struct SearchUsersWithPaginationRequest: GitHubRequest {
        typealias Response = SearchResponse<User>
        
        let path: String = "/search/users"
        let method: HTTPMethod = .get
        
        let query: String
        let page: Int?
        let perPage: Int?
        
        var queryItems: [URLQueryItem] {
            var queryItems = [URLQueryItem(name: "q", value: query)]
            
            if let page = page {
                let query = URLQueryItem(name: "page", value: String(page))
                queryItems.append(query)
            }
            if let perPage = perPage {
                let query = URLQueryItem(name: "per_page", value: String(perPage))
                queryItems.append(query)
            }
            return queryItems
        }
    }
}




