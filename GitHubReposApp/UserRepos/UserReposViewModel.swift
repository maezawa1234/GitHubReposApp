import RxSwift
import RxCocoa

class UserReposViewModel {
    let sections: Driver<[UserReposSectionModel]>
    let listIsEmpty: Driver<Bool>
    let fetchingRepos: Driver<Bool>
    
    private let disposeBah = DisposeBag()
    
    init(user: User,
         dependencies: (
            wireFrame: Wireframe,
            model: UserReposModelProtocol)
    ) {
        let fetchingRepos = ActivityIndicator()
        self.fetchingRepos = fetchingRepos.asDriver()
        
        self.sections = dependencies.model
            .fetchRepositories(by: user.login)
            .trackActivity(fetchingRepos)
            .asDriver(onErrorDriveWith: .empty())
            .map { repositories -> [UserReposSectionModel] in
                let sectionModel = UserReposSectionModel(header: "Repositories", items: repositories)
                return [sectionModel]
            }
        
        sections.drive(onNext: { _ in
        })
        .disposed(by: disposeBah)
        
        self.listIsEmpty = self.sections
            .map { $0[0].items.isEmpty }
    }
}
