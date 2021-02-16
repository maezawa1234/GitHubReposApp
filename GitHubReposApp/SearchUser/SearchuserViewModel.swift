
import RxSwift
import RxCocoa

class SearchUserViewModel {
    //Drivers
    let sections: Driver<[SearchUserSectionModel]>
    let error: Driver<Bool>
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
        
        //let searchSequence = input.searchButtonClicked.withLatestFrom(input.searchBarText)
        let searchSequence = input.searchBarText
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .asObservable()
            .flatMapLatest { text in
                return model.fetchUser(query: text)
                    .materialize()
            }
            .share(replay: 1)
        
        self.sections = searchSequence.elements()
            .asDriver(onErrorDriveWith: .empty())
            .map { users in
                sections[0].items = users
                return sections
            }
        
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
            .drive(onNext: { erorr in
                print("エラーおきたよ")
            })
            .disposed(by: disposeBag)
        
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
