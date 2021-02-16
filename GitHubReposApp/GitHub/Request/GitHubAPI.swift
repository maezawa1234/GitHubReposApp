import Foundation

final class GitHubAPI {
    struct SearchRepositories: GitHubRequest {
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
    
    struct SearchUsers: GitHubRequest {
        let keyword: String
        
        typealias Response = SearchResponse<User>
        
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
    
    struct UserRepositories: GitHubRequest {
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
}



