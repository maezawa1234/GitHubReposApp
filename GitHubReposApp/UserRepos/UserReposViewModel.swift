import RxSwift
import RxCocoa

class UserReposViewModel {
    let sections: Driver<[UserReposSectionModel]>
    let listIsEmpty: Driver<Bool>
    let fetchingRepos: Driver<Bool>
    
    let updateCell: Driver<IndexPath>
    
    private let disposeBag = DisposeBag()
    
    init(user: User,
         favoriteButtonClicked: Driver<(indexPath: IndexPath, repoStatus: RepoStatus, isFavorite: Bool)>,
         dependencies: (
            wireFrame: Wireframe,
            model: UserReposModelProtocol,
            dataStore: DataStoreProtocol)
    ) {
        let webClient = dependencies.model
        let dataStore = dependencies.dataStore
        
        let fetchingRepos = ActivityIndicator()
        self.fetchingRepos = fetchingRepos.asDriver()
        
        let fetchRepositoriesResponse = webClient
            .fetchRepositories(by: user.login)
            .trackActivity(fetchingRepos)
            .asDriver(onErrorDriveWith: .empty())
            //APIで取得したリポジトリ配列をDataStoreへ保存
            .flatMap { repos -> Driver<[Repository]> in
                return dataStore.save(repos: repos)
                    .asDriver(onErrorDriveWith: .empty())
            }
    
        //MARK: お気に入り状態をdataStoreへ保存
        let favoriteEvent = favoriteButtonClicked
            //FIXME: イベントの値Boolはてきとう、使用していない状態です。
            .flatMap { statusValue -> Driver<Bool> in
                let row = statusValue.indexPath.row
                let repoStatus = statusValue.repoStatus
                let isFavorite = statusValue.isFavorite
                print("In ViewModel Event, will save isFavorite", isFavorite)
                return dataStore.save(liked: isFavorite, for: repoStatus.repo.id)
                    .asDriver(onErrorDriveWith: .empty())
            }
            .startWith(true)
            
        self.updateCell = favoriteButtonClicked
            .map {
                return $0.indexPath
            }
        
        self.sections = Driver.combineLatest(fetchRepositoriesResponse, favoriteEvent) { ($0, $1) }
            .flatMap { o -> Driver<RepoStatusList> in
                print("aaaaaaaaaaaaaaaaa")
                //MARK: RepositoryをRepoStatusに変換する. dataStoreからお気に入り情報の取得を開始
                let repositories = o.0
                let ids = repositories.map { $0.id }
                return dataStore.fetch(ids: ids)
                    .map { likes in
                        print(likes)
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
        .disposed(by: disposeBag)
        
        self.listIsEmpty = self.sections
            .map { $0[0].items.isEmpty }
    }
}
