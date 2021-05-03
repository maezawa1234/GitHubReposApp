import RxSwift
import RxCocoa
import Action

protocol RepositoryDetailViewModelInput: AnyObject {
    var favoriteButtonClicked: PublishRelay<Bool> { get }
    var webViewEstimatedProgress: PublishRelay<Double?> { get }
}

protocol RepositoryDetailViewModelOutput: AnyObject {
    var isFavorite: Driver<String> { get }
    var estimatedProgress: Driver<Double> { get }
}

protocol RepositoryDetailViewModelType {
    var input: RepositoryDetailViewModelInput { get }
    var output: RepositoryDetailViewModelOutput { get }
}

class RepositoryDetailViewModel: RepositoryDetailViewModelType, RepositoryDetailViewModelInput, RepositoryDetailViewModelOutput {
    var input: RepositoryDetailViewModelInput { return self }
    var output: RepositoryDetailViewModelOutput { return self }
    
    //MARK: - Input
    var favoriteButtonClicked = PublishRelay<Bool>()
    var webViewEstimatedProgress = PublishRelay<Double?>()
    
    //MARK: - Output
    var isFavorite: Driver<String>
    var estimatedProgress: Driver<Double>
    
    private let disposeBag = DisposeBag()
    
    init(repository: Repository,
         dataStore: DataStoreProtocol = UserDefaultsDataStore(userDefaults: UserDefaults.standard)) {
        
        let initialFavorite = dataStore.allLikes().map { $0[repository.id] ?? false }
        
        let saveFavoriteAction: Action<Bool, Bool> = Action { isFavorite in
            return dataStore.save(isFavorite: !isFavorite, for: repository.id)
        }
        
        favoriteButtonClicked
            .bind(to: saveFavoriteAction.inputs)
            .disposed(by: disposeBag)
         
        self.isFavorite = Observable.concat(initialFavorite.asObservable(), saveFavoriteAction.elements)
            .map { $0 ? "⭐" : "☆" }
            .asDriver(onErrorDriveWith: .empty())
        
        self.estimatedProgress = webViewEstimatedProgress
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .empty())
    }
}
