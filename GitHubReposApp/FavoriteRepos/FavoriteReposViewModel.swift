import RxSwift
import RxCocoa

class FavoriteReposViewModel {
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
                print("In ViewModel Event, will save isFavorite", isFavorite)
                return dataStore.save(liked: isFavorite, for: repoStatus.repo.id)
                    .asDriver(onErrorDriveWith: .empty())
            }
            .startWith(true)
        
        let reposStatusList = Driver.combineLatest(input.viewWillAppear, favoriteEvent)
            .flatMap { _ in
                return dataStore.allLikes().asDriver(onErrorDriveWith: .empty())
            }
            .flatMap { o -> Driver<RepoStatusList> in
                let likes = o
                let ids = Array(likes.keys)
                return dependencies.dataStore.fetch(using: ids)
                    .map { repos -> RepoStatusList in
                        let likesList = RepoStatusList(
                            repos: repos,
                            favoriteStatuses: likes,
                            isOnlyFavorite: true
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
        
        self.sections.drive(onNext: { _ in
        })
        .disposed(by: disposeBag)
        
        self.listIsEmpty = self.sections
            .map {$0[0].items.isEmpty }
        
        self.transitionToRepoDetailView = input.cellSelected
            .withLatestFrom(reposStatusList) { (indexPath: $0, repositories: $1) }
            .map { $0.repositories.statuses[$0.indexPath.row].repo }
    }
}


