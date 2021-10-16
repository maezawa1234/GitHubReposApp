import RxSwift
import RxCocoa

class FavoriteReposViewModel {
    //MARK: Drivers
    let sections: Driver<[UserReposSectionModel]>
    let listIsEmpty: Driver<Bool>
    let transitionToRepoDetailView: Driver<Repository>
    
    private let disposeBag = DisposeBag()
    
    init(input: (
            cellSelected: Driver<IndexPath>,
            favoriteButtonClicked: Driver<(indexPath: IndexPath, repoStatus: RepoStatus)>,
            viewWillAppear: Driver<Void>),
         dependencies: (
            wireFrame: Wireframe,
            dataStore: DataStoreProtocol)
    ) {
        let dataStore = dependencies.dataStore
        
        //MARK: お気に入り状態をdataStoreへ保存
        let favoriteEvent = input.favoriteButtonClicked
            //FIXME: イベントの値Boolはてきとう、使用していない状態です。
            .flatMap { statusValue -> Driver<Bool> in
                let repoStatus = statusValue.repoStatus
                let isFavorite = !repoStatus.isFavorite  // お気に入り状態を反転
                return dataStore.save(isFavorite: isFavorite, for: repoStatus.repo.id)
                    .asDriver(onErrorDriveWith: .empty())
            }
            .startWith(true)
        
        let reposStatusList = Driver.combineLatest(input.viewWillAppear, favoriteEvent)
            .flatMapLatest { _ in
                return dataStore.allLikes().asDriver(onErrorDriveWith: .empty())
            }
            .flatMapLatest { o -> Driver<RepoStatusList> in
                let likes = o
                let ids = Array(likes.keys)
                return dependencies.dataStore.fetch(using: ids)
                    .map { repos -> RepoStatusList in
                        let likesList = RepoStatusList(
                            repos: repos,
                            favoriteStatuses: likes,
                            isOnlyFavorite: true,
                            sortBy: {
                                ($0.repo.owner.login == $1.repo.owner.login) ? $0.repo.name < $1.repo.name : ($0.repo.owner.login < $1.repo.owner.login)
                            }
                        )
                        return likesList
                    }
                    .asDriver(onErrorDriveWith: .empty())
            }
        
        self.sections = reposStatusList
            .map { reposStatusList -> [UserReposSectionModel] in
                let sectionModel = UserReposSectionModel(
                    header: "Repositories",
                    items: reposStatusList.statuses
                )
                return [sectionModel]
            }
            .asDriver(onErrorDriveWith: .empty())
        
        self.sections.drive(onNext: { a in
        })
        .disposed(by: disposeBag)
        
        self.listIsEmpty = self.sections
            .map {$0[0].items.isEmpty }
        
        self.transitionToRepoDetailView = input.cellSelected
            .withLatestFrom(reposStatusList) { (indexPath: $0, repositories: $1) }
            .map { $0.repositories.statuses[$0.indexPath.row].repo }
    }
}


