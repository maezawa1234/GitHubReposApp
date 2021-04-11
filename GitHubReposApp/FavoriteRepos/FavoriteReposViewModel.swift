import RxSwift
import RxCocoa

class FavoriteReposViewModel {
    let sections: Driver<[UserReposSectionModel]>
    
    private let disposeBag = DisposeBag()
    
    init(input: (
            viewWillAppear: Driver<Void>,
            favoriteButtonClicked: Driver<(indexPath: IndexPath, repoStatus: RepoStatus)>),
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
        
        let firstSections = Driver.combineLatest(input.viewWillAppear, favoriteEvent)
            .flatMap { _ in
                return dataStore.allLikes().asDriver(onErrorDriveWith: .empty())
            }
            .flatMap { o -> Driver<RepoStatusList> in
                let likes = o
                let ids = Array(likes.keys)
                print("likes: ", likes)
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
            .map { reposStatusList -> [UserReposSectionModel] in
                let sectionModel = UserReposSectionModel(
                    header: "Repositories",
                    items: reposStatusList.statuses
                )
                return [sectionModel]
            }
            .asDriver(onErrorDriveWith: .empty())
        
        self.sections = firstSections
        
        self.sections.drive(onNext: { _ in
        })
        .disposed(by: disposeBag)
    }
}


