import RxSwift

protocol WebAPIClientProtocol {
    func fetchUsers(query: String) -> Single<(users: [User], totalCount: Int)>
    func fetchRepositories(by userName: String) -> Single<[Repository]>
    func fetchUsers(query: String, page: Int) -> Observable<(users: [User], totalCount: Int, pagination: Pagination)>
}

class WebAPIClient: WebAPIClientProtocol {
    static let shared = WebAPIClient()
    private init() {}
    
    private let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        return session
    }()
    
    func fetchUsers(query: String) -> Single<(users: [User], totalCount: Int)> {
        return Single.create { [weak self] observer in
            let request = GitHubAPI.SearchUsersRequest(keyword: query)
            let urlRequest = request.buildURLRequest()
            print("URLRequest:", urlRequest)
            
            let task = self?.session.dataTask(with: urlRequest) { data, response, error in
                switch (data, response, error) {
                case (_, _, let error?):
                    //クロージャ引数'observer'の型はクロージャ.　よってobserver("引数")でクロージャを実行している構文
                    observer(.error(GitHubClientError.connectionError(error)))
                    print("connection error")
                    
                case (let data?, let response?, _):
                    do {
                        print(data)
                        let response = try request.response(from: data, urlResponse: response)
                        observer(.success((users: response.items, totalCount: response.totalCount)))
                    } catch let error as GitHubAPIError {
                        observer(.error(GitHubClientError.apiError(error)))
                    } catch {
                        observer(.error(GitHubClientError.responseParseError(error)))
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
    
    func fetchRepositories(by userName: String) -> Single<[Repository]> {
        
        return Single.create { [weak self] observer in
            let request = GitHubAPI.UserRepositoriesRequest(userName: userName)
            
            let urlRequest = request.buildURLRequest()
            print("urlRequest:", urlRequest)
            
            let task = self?.session.dataTask(with: urlRequest) { data, response, error in
                switch (data, response, error) {
                case (_, _, let error?):
                    observer(.error(GitHubClientError.connectionError(error)))
                    print("connection error")
                    
                case (let data?, let response?, _):
                    do {
                        let response = try request.response(from: data, urlResponse: response)
                        observer(.success(response.repositories))
                        print("success")
                        
                    } catch let error as GitHubAPIError {
                        observer(.error(GitHubClientError.apiError(error)))
                        print("api error")
                        
                    } catch {
                        observer(.error(GitHubClientError.responseParseError(error)))
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
    
    func fetchUsers(query: String, page: Int = 1) -> Observable<(users: [User], totalCount: Int, pagination: Pagination)> {
        return Observable.create { [weak self] observer in
            let request = GitHubAPI.SearchUsersWithPaginationRequest(query: query, page: page, perPage: nil)
            let urlRequest = request.buildURLRequest()
            print("URLRequest:", urlRequest)
            
            let task = self?.session.dataTask(with: urlRequest) { data, response, error in
                switch (data, response, error) {
                case (_, _, let error?):
                    observer.onError(GitHubClientError.connectionError(error))
                    //observer(.error(GitHubClientError.connectionError(error)))
                    print("connection error")
                    
                case (let data?, let response?, _):
                    do {
                        print(data)
                        let response = try request.responseWithPagination(from: data, urlResponse: response)
                        print("users count:", response.0.items.count)
                        
                        typealias ResponseObject = (users: [User], totalCount: Int, pagination: Pagination)
                        
                        let responseObject = ResponseObject(users: response.0.items,
                                                            totalCount: response.0.totalCount,
                                                            pagination: response.1)
                        
                        observer.onNext(responseObject)
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
