import RxSwift
import RxCocoa

class UserReposViewModel {
    let sections: Driver<[UserReposSectionModel]>
    let listIsEmpty: Driver<Bool>
    let fetchingRepos: Driver<Bool>
    
    private let disposeBah = DisposeBag()
    
    init(user: User,
         favoriteButtonClicked: Driver<IndexPath>,
         dependencies: (
            wireFrame: Wireframe,
            model: UserReposModelProtocol,
            dataStore: DataStoreProtocol)
    ) {
        let dataStore = dependencies.dataStore
        let fetchingRepos = ActivityIndicator()
        self.fetchingRepos = fetchingRepos.asDriver()
        
        self.sections = dependencies.model
            .fetchRepositories(by: user.login)
            .trackActivity(fetchingRepos)
            .asDriver(onErrorDriveWith: .empty())
            .flatMap { repositories -> Driver<RepoStatusList> in
                //MARK: RepositoryをRepoStatusに変換する. dataStoreからお気に入り情報の取得を開始
                let ids = repositories.map { $0.id }
                return dataStore.fetch(ids: ids)
                    .map { likes in
                        let statusList = RepoStatusList(
                            repos: repositories, favoriteStatuses: likes
                        )
                        return statusList
                    }
                    .asDriver(onErrorDriveWith: .empty())
            }
            .map { reposStatusList -> [UserReposSectionModel] in
                let sectionModel = UserReposSectionModel(header: "Repositories", items: reposStatusList.statuses)
                return [sectionModel]
            }
        
        sections.drive(onNext: { _ in
        })
        .disposed(by: disposeBah)
        
        self.listIsEmpty = self.sections
            .map { $0[0].items.isEmpty }
        
        //MARK: お気に入り状態をdataStoreへ保存
        Driver.combineLatest(favoriteButtonClicked, sections) { (indexPath: $0, sections: $1) }
        .drive(onNext: { statusValue in
            let row = statusValue.indexPath.row
            let repoStatus = statusValue.sections[0].items[row]
            let _ = dataStore.save(liked: true, for: repoStatus.repo.id)
        })
        .disposed(by: disposeBah)
    }
}
