import Foundation

protocol GitHubRequest {
    associatedtype Response: Decodable
    
    var baseURL: URL{ get }
    var path: String{ get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem] { get }
}

extension GitHubRequest {
    var baseURL :URL{
        return URL(string: "https://api.github.com")!
    }
    
    func buildURLRequest() -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        switch method {
        case .get:
            components?.queryItems = queryItems
            
        default:
            fatalError("Unsupported method\(method)")
        }
        
        var urlReqest = URLRequest(url: url)
        urlReqest.url = components?.url
        urlReqest.httpMethod = method.rawValue
        
        return urlReqest
    }
    
    func response(from data: Data,
                  urlResponse: URLResponse) throws -> Response {
        let decoder = JSONDecoder()
        
        if case (200 ..< 300)? = (urlResponse as? HTTPURLResponse)?.statusCode {
            //JSONからモデルをインスタンス化
            return try decoder.decode(Response.self, from: data)
        } else {
            //JSONからAPIエラーをインスタンス化
            throw try decoder.decode(GitHubAPIError.self, from: data)
        }
    }
    
    func responseWithPagination(from data: Data, urlResponse: URLResponse) throws -> (Response, Pagination) {
        let decoder = JSONDecoder()
        
        if case (200 ..< 300)? = (urlResponse as? HTTPURLResponse)?.statusCode {
            //JSONからモデルをインスタンス化
            let object = try decoder.decode(Response.self, from: data)
            
            guard let response = urlResponse as? HTTPURLResponse else {
                throw try decoder.decode(GitHubAPIError.self, from: data)
            }
            let pagination: Pagination
            if let link = response.allHeaderFields["Link"] as? String {
                pagination = Pagination(link: link)
            } else {
                pagination = Pagination(next: nil, last: nil, first: nil, prev: nil)
            }
            
            return (object, pagination)
        } else {
            //JSONからAPIエラーをインスタンス化
            throw try decoder.decode(GitHubAPIError.self, from: data)
        }
    }
}


