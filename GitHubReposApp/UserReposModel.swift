import RxSwift

protocol UserReposModelProtocol {
    func fetchRepositories(by userName: String) -> Observable<[Repository]>
}

class UserReposModel: UserReposModelProtocol {
    private let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        return session
    }()
    
    func fetchRepositories(by userName: String) -> Observable<[Repository]> {
        
        return Observable.create { [weak self] observer in
            let request = GitHubAPI.UserRepositories(userName: userName)
            
            let urlRequest = request.buildURLRequest()
            print("urlRequest:", urlRequest)
        
            let task = self?.session.dataTask(with: urlRequest) { data, response, error in
                switch (data, response, error) {
                case (_, _, let error?):
                    observer.onError(GitHubClientError.connectionError(error))
                    print("connection error")
                    
                case (let data?, let response?, _):
                    do {
                        print(data)
                        let response = try request.response(from: data, urlResponse: response)
                        observer.onNext(response.repositories)
                        print("success")
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
