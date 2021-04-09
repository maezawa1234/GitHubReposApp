import RxSwift
import RxCocoa

class FavoriteReposViewModel {
    let sections: Driver<[UserReposSectionModel]>
    
    private let disposeBag = DisposeBag()
    
    init(dependencies: (
            wireFrame: Wireframe,
            dataStore: DataStoreProtocol)
    ) {
        self.sections  = dependencies.dataStore.allLikes()
            .flatMap { likes -> Driver<RepoStatusList> in
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
    }
    
}


