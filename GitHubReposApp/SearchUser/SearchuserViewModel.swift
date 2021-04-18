import RxSwift
import RxCocoa

class SearchUserViewModel {
    //Drivers
    let sections: Driver<[SearchUserSectionModel]>
    let error: Driver<Bool>
    let transitionToReposView: Driver<UserCellData>
    let listIsEmpty: Driver<Bool>
    let totalCount: Driver<Int>
    let isSearchFieldEditing: Driver<Bool>
    let fetchingUsers: Driver<Bool>
    
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
        let model = dependency.model
        let wireFrame = dependency.wireFrame
        
        let fetchingUsers = ActivityIndicator()
        self.fetchingUsers = fetchingUsers.asDriver()
        
        input.isBottomEdge
            .drive(onNext: { isBottom in
                print("isNearBottom: ", isBottom)
            })
            .disposed(by: disposeBag)
        
        var sections = [SearchUserSectionModel(header: "Users", items: []), SearchUserSectionModel(header: "Footer", items: [SearchUserCellDataType.footerItem(FooterCellData(id: -1000000, isAnimation: true))])]
        
        var nowPagination: Pagination? = nil {
            didSet {
                print(nowPagination?.first, nowPagination?.last, nowPagination?.next, nowPagination?.prev)
            }
        }

        let searchSequence = input.searchButtonClicked
            .withLatestFrom(input.searchBarText)
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .asObservable()
            .flatMapLatest { text -> Observable<Event<(users: [User], totalCount: Int, pagination: Pagination)>> in
                return model.fetchUsers(query: text, page: 1)
                    .map { o -> (users: [User], totalCount: Int, pagination: Pagination) in
                        nowPagination = o.pagination
                        return (users: o.users, totalCount: o.totalCount, pagination: o.pagination)
                    }
                    .trackActivity(fetchingUsers)
                    .materialize()
            }
            .share(replay: 1)
        
        self.fetchingUsers
            .drive(onNext: { isFetching in
                print("isFetching: ", isFetching)
            })
            .disposed(by: disposeBag)
        
        let addSearchSequense = input.isBottomEdge.filter { $0 }
            .withLatestFrom(input.searchBarText)
            .filter { !$0.isEmpty }
            //.distinctUntilChanged()
            .asObservable()
            //.withLatestFrom(paginationObservable1) { (text: $0, pagination: $1) }
            .flatMapLatest { text -> Observable<Event<(users: [User], totalCount: Int)>> in
                guard let next = nowPagination?.next else {
                    return .empty()
                }
                return model.fetchUsers(query: text, page: next)
                    .map { o -> (users: [User], totalCount: Int) in
                        nowPagination = o.pagination
                        return (users: o.users, totalCount: o.totalCount)
                    }
                    .materialize()
            }
            .share(replay: 1)
        
        let response = searchSequence.elements()
            .asDriver(onErrorDriveWith: .empty())
        
        let responseSectionData = response.map { response -> [SearchUserSectionModel] in
            let items = response.users.map { SearchUserCellDataType.userItem(UserCellData(user: $0)) }
            sections[0].items = items
            return sections
        }
        
        let addResponse = addSearchSequense.elements()
            .asDriver(onErrorDriveWith: .empty())
            .map { response -> [SearchUserSectionModel] in
                let items = response.users.map { SearchUserCellDataType.userItem(UserCellData(user: $0)) }
                sections[0].items.append(contentsOf: items)
                sections[0].items = sections[0].items.unique(resolve: { _, _ in
                                            print("Duplicate values will be assigned.")
                                            return .ignoreNewOne
                })
                if let pagination = nowPagination {
                    if pagination.last == nil && pagination.next == nil {
                        sections[1].items.removeAll()
                    }
                }
                return sections
            }
        
        self.sections = Driver.merge(responseSectionData, addResponse)
        
        self.sections.drive(onNext: { _ in
            print("")
        })
        .disposed(by: disposeBag)
        
        
        self.totalCount = response
            .map { $0.totalCount }
        
        self.error = Observable.merge(searchSequence.errors(), addSearchSequense.errors())
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
            .filter { $0 != nil }
            .map { $0! }
        
        let didBeginEditing = input.searchBarDidBeginEditing.map { true }
        let didEndEditing = Driver.merge(input.searchButtonClicked, input.cancelButtonClicked)
            .map { false }
        self.isSearchFieldEditing = Driver.merge(didBeginEditing, didEndEditing)
    }
}
