import RxSwift
import RxCocoa
import Action

protocol SearchUserViewModelInputs: AnyObject {
    var searchBarText: PublishRelay<String> { get }
    var searchBarDidBeginEditing: PublishRelay<Void> { get }
    var searchButtonClicked: PublishRelay<Void> { get }
    var closeButtonClicked: PublishRelay<Void> { get }
    var itemSelected: PublishRelay<IndexPath> { get }
    var loadAdditionalUsers: PublishRelay<Void> { get }
}

protocol SearchUserViewModelOutputs: AnyObject {
    var userSections: Driver<[SearchUserSectionModel]> { get }
    var transitionToReposView: Driver<UserCellData> { get }
    var totalCount: Driver<Int> { get }
    var listIsEmpty: Driver<Bool> { get }
    var isSearchFieldEditing: Driver<Bool> { get }
    var isFetching: Driver<Bool> { get }
    var isErrorOccured: Driver<String> { get }
    var isLoadingFooterHidden: Driver<Bool> { get }
}

protocol SearchUserViewModelType: AnyObject {
    var inputs: SearchUserViewModelInputs { get }
    var output: SearchUserViewModelOutputs { get }
}

final class SearchUserViewModel: SearchUserViewModelInputs, SearchUserViewModelOutputs, SearchUserViewModelType {
    
    // MARK: - properties
    var inputs: SearchUserViewModelInputs { return self }
    var output: SearchUserViewModelOutputs { return self }
    
    // MARK: - Input Sources
    var searchBarText = PublishRelay<String>()
    var searchBarDidBeginEditing = PublishRelay<Void>()
    var searchButtonClicked = PublishRelay<Void>()
    var closeButtonClicked = PublishRelay<Void>()
    var itemSelected = PublishRelay<IndexPath>()
    var loadAdditionalUsers = PublishRelay<Void>()
    
    //MARK: - Output Sources
    var userSections: Driver<[SearchUserSectionModel]>
    var transitionToReposView: Driver<UserCellData>
    var totalCount: Driver<Int>
    var listIsEmpty: Driver<Bool>
    var isSearchFieldEditing: Driver<Bool>
    var isFetching: Driver<Bool>
    var isErrorOccured: Driver<String>
    var isLoadingFooterHidden: Driver<Bool>
    
    typealias APIUsersResultType = (users: [User], totalCount: Int, pagination: Pagination)
    
    private let searchUsersAction: Action<String, APIUsersResultType>
    private let searchAdditionalUsersAction: Action<String, APIUsersResultType>
    
    private let _users = BehaviorRelay<[User]>(value: [])
    private let _pagenation = BehaviorRelay<Pagination?>(value: nil)
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Initialize
    init(model: WebAPIClientProtocol) {
        self.searchUsersAction = Action { searchText in
            return model
                .fetchUsers(query: searchText, page: 1)
        }
        self.searchAdditionalUsersAction = Action { [weak _pagenation] searchText in
            guard let next = _pagenation?.value?.next else { return .empty() }
            return model
                .fetchUsers(query: searchText, page: next)
                .asObservable()
        }
        
        self.isFetching = searchUsersAction.executing.asDriver(onErrorDriveWith: .empty())
        
        self.userSections = _users
            .map {
                let users = $0.map { UserCellData(user: $0) }
                return [SearchUserSectionModel(header: "Users", items: users)]
            }
            .asDriver(onErrorDriveWith: .empty())
        
        let searchUsers = searchUsersAction.elements
            .share(replay: 1)
            .map { $0.users }
        
        let addtionalSearchUsers = searchAdditionalUsersAction.elements
            .withLatestFrom(_users) { ($0, $1) }
            .map { response, users -> [User] in
                let currentUsers = users
                return currentUsers + response.users
            }
            .map { $0.unique(resolve: { _, _ in .ignoreNewOne }) }
        
        Observable.merge(searchUsers, addtionalSearchUsers)
            .bind(to: _users)
            .disposed(by: disposeBag)
            
        searchUsersAction.elements
            .map { $0.pagination }
            .bind(to: _pagenation)
            .disposed(by: disposeBag)
        
        // Search users
        searchButtonClicked
            .asObservable()
            .withLatestFrom(searchBarText)
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .bind(to: searchUsersAction.inputs)
            .disposed(by: disposeBag)
        
        // Error
        self.isErrorOccured = Observable
            .merge(searchUsersAction.underlyingError, searchAdditionalUsersAction.underlyingError)
            .map {
                if let apiError = $0 as? GitHubAPIError {
                    return apiError.message
                }
                else { return nil }
            }
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .empty())
        
        // Additional loading users
        loadAdditionalUsers.asObservable()
            .withLatestFrom(searchBarText)
            .takeUntil(isErrorOccured.asObservable())
            .bind(to: searchAdditionalUsersAction.inputs)
            .disposed(by: disposeBag)
        
        self.transitionToReposView = itemSelected
            .withLatestFrom(userSections) { (indexPath: $0, sections: $1) }
            .map { $0.sections[0].items[$0.indexPath.row] }
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .empty())
        
        self.totalCount = Observable.merge(searchUsersAction.elements, searchAdditionalUsersAction.elements)
            .map { $0.totalCount }
            .asDriver(onErrorDriveWith: .empty())
        
        self.listIsEmpty = _users
            .skip(1)
            .map { $0.isEmpty }
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
        
        let didBeginEditing = searchBarDidBeginEditing
            .map { true }
        let didEndEditing = Observable
            .merge(searchButtonClicked.asObservable(), closeButtonClicked.asObservable())
            .map { false }
        self.isSearchFieldEditing = Observable
            .merge(didBeginEditing, didEndEditing)
            .asDriver(onErrorDriveWith: .empty())
        
        self.isLoadingFooterHidden = searchAdditionalUsersAction.executing
            .asDriver(onErrorDriveWith: .empty())
            .distinctUntilChanged()
    }
}
