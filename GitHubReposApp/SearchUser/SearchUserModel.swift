
import RxSwift

protocol SearchUserModelProtocol {
    func fetchUser(query: String) -> Observable<[User]>
}


class SearchUserModel: SearchUserModelProtocol {
    private let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        return session
    }()
    
    func fetchUser(query: String) -> Observable<[User]> {
        
        return Observable.create { [weak self] observer in
            let request = GitHubAPI.SearchUsers(keyword: query)
            
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
                        observer.onNext(response.items)
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


class SearchUserModelStub: SearchUserModelProtocol {
    func fetchUser(query: String) -> Observable<[User]> {
        
        return Observable.create { [weak self] observer in
            var users: [User] = []
            let usersCount = max(0, 10 - query.count)
            for i in 0 ... usersCount {
                let user = User(id: i, login: "♥UserName\(i)♥", avatarURL: URL(fileURLWithPath: "https://aaaa"), name: nil)
                users.append(user)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                observer.onNext(users)
                observer.onCompleted()
            }
            return Disposables.create()
        }
        
    }
}
