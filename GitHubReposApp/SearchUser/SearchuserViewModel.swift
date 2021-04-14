import RxSwift
import RxCocoa

class SearchUserViewModel {
    //Drivers
    let sections: Driver<[SearchUserSectionModel]>
    let error: Driver<Bool>
    let transitionToReposView: Driver<UserCellData>
    let listIsEmpty: Driver<Bool>
    let totalCount: Driver<Int>
    let isSearchFieldEditing: Signal<Bool>
    let fetchingUsers: Driver<Bool>
    
    private let disposeBag = DisposeBag()
    
    init(input: (
            searchBarText: Driver<String>,
            searchBarDidBeginEditing: Signal<Void>,
            searchButtonClicked: Signal<Void>,
            cancelButtonClicked: Signal<Void>,
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
        
        let searchSequence = input.searchButtonClicked
            .withLatestFrom(input.searchBarText)
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .asObservable()
            .flatMapLatest { text in
                return model.fetchUsers(query: text, page: 1)
                    .map {
                        (users: $0.users, totalCount: $0.totalCount)
                    }
                    .trackActivity(fetchingUsers)
                    .materialize()
            }
            .share(replay: 1)
        
        let response = searchSequence.elements()
            .asDriver(onErrorDriveWith: .empty())
        
        self.sections = response
            .map { response in
                let items = response.users.map { SearchUserCellDataType.userItem(UserCellData(user: $0)) }
                sections[0].items = items
                return sections
            }
        
        self.totalCount = response
            .map { $0.totalCount }
        
        self.error = searchSequence.errors()
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
        let didEndEditing = Signal.merge(input.searchButtonClicked, input.cancelButtonClicked)
            .map { false }
        self.isSearchFieldEditing = Signal.merge(didBeginEditing, didEndEditing)
    }
}
