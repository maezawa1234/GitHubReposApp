
import RxSwift
import RxCocoa

class SearchUserViewModel {
    //Drivers
    let sections: Driver<[SearchUserSectionModel]>
    let transitionToReposView: Driver<User>
    let listIsEmpty: Driver<Bool>
    
    private let disposeBag = DisposeBag()
    
    init(input: (
            searchBarText: Driver<String>,
            searchButtonClicked: Signal<Void>,
            itemSelected: Driver<IndexPath>),
         dependency: (
            wireFrame: Wireframe,
            model: SearchUserModelProtocol)
         ) {
        let model = dependency.model
        let wireFrame = dependency.wireFrame
        
        var sections = [SearchUserSectionModel(header: "Users", items: [])]
        
        self.sections = input.searchButtonClicked.withLatestFrom(input.searchBarText)
            .flatMapLatest { text in
                return model
                    .fetchUser(query: text)
                    .asDriver(onErrorDriveWith: .empty())
                    .map { users in
                        sections[0].items = users
                        return sections
                    }
            }
        
        self.listIsEmpty = self.sections
            .map { $0[0].items.isEmpty }
        
        self.transitionToReposView = input.itemSelected
            .withLatestFrom(self.sections) {
                return (indexPath: $0, sections: $1)
            }
            .map {
                let items = $0.sections[0].items
                return items[$0.indexPath.row]
            }
    }
}
