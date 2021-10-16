import RxSwift
import RxCocoa
import Action

class UserReposViewModel {

    // MARK: - Drivers
    let sections: Driver<[UserReposSectionModel]>
    let listIsEmpty: Driver<Bool>
    let fetchingRepos: Driver<Bool>
    let transitionToRepoDetailView: Driver<Repository>
    
    private let disposeBag = DisposeBag()
    
    init(user: UserCellData,
         input: (
            cellSelected: Driver<IndexPath>,
            favoriteButtonClicked: Driver<(indexPath: IndexPath, repoStatus: RepoStatus)>,
            viewWillAppear: Driver<Void>),
         dependencies: (
            wireFrame: Wireframe,
            webClient: WebAPIClientProtocol,
            dataStore: DataStoreProtocol)
    ) {
        let webClient = dependencies.webClient
        let dataStore = dependencies.dataStore
        
        let fetchingRepos = ActivityIndicator()
        self.fetchingRepos = fetchingRepos.asDriver()
        
        // MARK: - Action
        let saveAction: Action<[Repository], [Repository]> = Action(workFactory: { repos in
            return dataStore.save(repos: repos)
        })
        
        webClient.fetchRepositories(by: user.login)
            .trackActivity(fetchingRepos)
            .bind(to: saveAction.inputs)
            .disposed(by: disposeBag)
        
        /*
        let favoriteRegisterAction: Action<(indexPath: IndexPath, repoStatus: RepoStatus), Bool> = Action { statusValue in
            let repoStatus = statusValue.repoStatus
            return dataStore.save(liked: !statusValue.repoStatus.isFavorite, for: repoStatus.repo.id)
        }
        */
        // MARK: - お気に入り状態をdataStoreへ保存
        let favoriteEvent = input.favoriteButtonClicked
            //FIXME: イベントの値Boolはてきとう、使用していない状態です。
            .flatMap { statusValue -> Driver<Bool> in
                let repoStatus = statusValue.repoStatus
                return dataStore.save(isFavorite: !repoStatus.isFavorite, for: repoStatus.repo.id)
                    .asDriver(onErrorDriveWith: .empty())
            }
            //combineでイベント流れるようにとりあえず初期値'true'を流しておく
            .startWith(true)
        
        let userRepos = saveAction.elements.asDriver(onErrorDriveWith: .empty())
        
        self.sections = Driver
            .combineLatest(userRepos, favoriteEvent, input.viewWillAppear) { ($0, $1, $2) }
            .flatMapLatest { reposAndFavoriteEvent -> Driver<RepoStatusList> in
                //MARK: - RepositoryをRepoStatusに変換する. dataStoreからお気に入り情報の取得を開始
                let repositories = reposAndFavoriteEvent.0
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
        .disposed(by: disposeBag)
        
        self.listIsEmpty = self.sections
            .map { $0[0].items.isEmpty }
        
        self.transitionToRepoDetailView = input.cellSelected
            .withLatestFrom(userRepos) { (indexPath: $0, repositories: $1) }
            .map { $0.repositories[$0.indexPath.row] }
    }
}
