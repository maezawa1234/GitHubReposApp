import RxSwift
import RxCocoa
import Action

class SearchUserViewModel {
    //Drivers
    let sections: Driver<[SearchUserSectionModel]>
    let error: Driver<Bool>
    let transitionToReposView: Driver<UserCellData>
    let listIsEmpty: Driver<Bool>
    let totalCount: Driver<Int>
    let isSearchFieldEditing: Driver<Bool>
    let isFetching: Driver<Bool>
    
    private let disposeBag = DisposeBag()
    
    init(input: (
            searchBarText: Driver<String>,
            searchBarDidBeginEditing: Driver<Void>,
            searchButtonClicked: Driver<Void>,
            cancelButtonClicked: Driver<Void>,
            itemSelected: Driver<IndexPath>,
            isBottomEdge: Driver<Bool>),
         dependency: (
            wireFrame: Wireframe,
            model: WebAPIClientProtocol)
    ) {
        typealias APIResultType = (users: [User], totalCount: Int, pagination: Pagination)
        
        let model = dependency.model
        let wireFrame = dependency.wireFrame
        
        let _nowPagination = BehaviorRelay<Pagination?>(value: nil)
        
        let isFetching = ActivityIndicator()
        self.isFetching = isFetching.asDriver()
        
        var sections = [SearchUserSectionModel(header: "Users", items: []),
                        SearchUserSectionModel(header: "Footer",
                                               items: [SearchUserCellDataType.footerItem(FooterCellData(isAnimation: true))])]
        
        let searchUsersAction: Action<String, APIResultType> = Action { searchText in
            return model.fetchUsers(query: searchText, page: 1)
                .trackActivity(isFetching)
        }
        
        let searchNextPageAction: Action<String, APIResultType> = Action { searchText in
            guard let nextPage = _nowPagination.value?.next else { return .empty() }
            return model
                .fetchUsers(query: searchText, page: nextPage)
                .asObservable()
        }
        
        // Trigger searching from search Bar
        input.searchButtonClicked
            .withLatestFrom(input.searchBarText)
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .drive(searchUsersAction.inputs)
            .disposed(by: disposeBag)
        
        // Trigger fetching next page users
        input.isBottomEdge
            .filter { $0 }
            .withLatestFrom(input.searchBarText)
            .filter { !$0.isEmpty }
            .drive(searchNextPageAction.inputs)
            .disposed(by: disposeBag)
        
        let apiResponse = Observable
            .merge(searchUsersAction.elements, searchNextPageAction.elements)
            .asDriver(onErrorDriveWith: .empty())
        
        // Bind nowPagination
        apiResponse
            .map { $0.pagination }
            .drive(_nowPagination)
            .disposed(by: disposeBag)
        
        let responseSectionModel = apiResponse
            .map { response -> [SearchUserSectionModel] in
                var prevItems = sections[0].items
                let addItems = response.users.map { SearchUserCellDataType.userItem(UserCellData(user: $0)) }
                prevItems.append(contentsOf: addItems)
                let newItems = prevItems.unique(resolve: { _, _ in .ignoreNewOne })
                sections[0].items = newItems
                return sections
            }
        
        self.sections = responseSectionModel
        
        self.totalCount = apiResponse
            .map { $0.totalCount }
        
        self.error = Observable
            .merge(searchUsersAction.errors, searchNextPageAction.errors)
            .asDriver(onErrorDriveWith: .empty())
            .flatMapLatest { error in
                return wireFrame.promptFor(error.localizedDescription, cancelAction: "OK", actions: [])
                    .map { _ in
                        return true
                    }
                    .asDriver(onErrorJustReturn: false)
            }
        
        self.error
            .drive(onNext: { error in
                print("error occured")
            })
            .disposed(by: disposeBag)
        
        self.listIsEmpty = self.sections
            .map { $0[0].items.isEmpty }
            .distinctUntilChanged()
        
        self.transitionToReposView = input.itemSelected
            .filter { $0.section == 0 }
            .withLatestFrom(self.sections) {
                return (indexPath: $0, sections: $1)
            }
            .map {
                return $0.sections[0].items[$0.indexPath.row]
            }
            .map { cellItem -> UserCellData? in
                switch cellItem {
                case .userItem(let userData):
                    return userData
                case .footerItem(_):
                    return nil
                }
            }
            .compactMap { $0 }
        
        let didBeginEditing = input.searchBarDidBeginEditing
            .map { true }
        let didEndEditing = Driver
            .merge(input.searchButtonClicked, input.cancelButtonClicked)
            .map { false }
        self.isSearchFieldEditing = Driver
            .merge(didBeginEditing, didEndEditing)
    }
}
