import RxSwift

protocol SearchUserModelProtocol {
    func fetchUser(query: String) -> Observable<(users: [User], totalCount: Int)>
}

class SearchUserModel: SearchUserModelProtocol {
    private let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        return session
    }()
    
    func fetchUser(query: String) -> Observable<(users: [User], totalCount: Int)> {
        
        return Observable.create { [weak self] observer in
            let request = GitHubAPI.SearchUsers(keyword: query)
            let urlRequest = request.buildURLRequest()
            print("URLRequest:", urlRequest)
            
            let task = self?.session.dataTask(with: urlRequest) { data, response, error in
                switch (data, response, error) {
                case (_, _, let error?):
                    observer.onError(GitHubClientError.connectionError(error))
                    print("connection error")
                    
                case (let data?, let response?, _):
                    do {
                        print(data)
                        let response = try request.response(from: data, urlResponse: response)
                        observer.onNext((users: response.items, totalCount: response.totalCount))
                        print("success item count:", response.totalCount)
                        observer.onCompleted()
                        
                    } catch let error as GitHubAPIError {
                        observer.onError(GitHubClientError.apiError(error))
                        print("api error")
                        
                    } catch {
                        observer.onError(GitHubClientError.responseParseError(error))
                        print("response parser error")
                    }
                    
                default:
                    fatalError("invalid response combination \(String(describing: data)), \(String(describing: response)), \(String(describing: error)).")
                }
            }
            task?.resume()
            return Disposables.create()
        }
        
    }
}
