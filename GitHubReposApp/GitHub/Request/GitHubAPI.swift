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
   
    /*
    struct SearchRepositoriesWithPaginationRequest: GitHubRequest {
        typealias Response = 
        
        
    }
     */
}




