
import RxSwift
import RxCocoa

class UserReposViewModel {
    private let disposeBah = DisposeBag()
    
    let sections: Driver<[UserReposSectionModel]>
    
    init(userName: String,
         viewDidAppear: Driver<Void>,
         dependencies: (
            wireFrame: Wireframe,
            model: UserReposModelProtocol)
    ) {
        
        let modelResponse = dependencies.model.fetchRepositories(by: userName)
        
        
        self.sections = viewDidAppear
            .flatMap { _ in
                return dependencies.model
                    .fetchRepositories(by: userName)
                    .asDriver(onErrorDriveWith: .empty())
                    .map { repositories -> [UserReposSectionModel] in
                        let sectionModel = UserReposSectionModel(header: "Repositories", items: repositories)
                        return [sectionModel]
                    }
            }
    }
}
