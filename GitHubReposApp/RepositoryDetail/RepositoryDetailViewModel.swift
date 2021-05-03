import RxSwift
import RxCocoa

protocol RepositoryDetailViewModelInput: AnyObject {
    var favoriteButtonClicked: PublishRelay<()> { get }
    var webViewEstimatedProgress: PublishRelay<Double?> { get }
}

protocol RepositoryDetailViewModelOutput: AnyObject {
    var isfavorite: Driver<String> { get }
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
    var favoriteButtonClicked = PublishRelay<()>()
    var webViewEstimatedProgress = PublishRelay<Double?>()
    
    //MARK: - Output
    var isfavorite: Driver<String>
    var estimatedProgress: Driver<Double>
    
    private let disposeBag = DisposeBag()
    
    init(repository: Repository,
         dataStore: DataStoreProtocol = UserDefaultsDataStore.shared) {
        
        let nowFavorite = BehaviorRelay<Bool>(value: true)
        let firstStatus = dataStore.allLikes().map { allFavorites -> Bool in
            let isFavorite = allFavorites[repository.id] ?? false
            nowFavorite.accept(isFavorite)
            return isFavorite
        }
        
        let likeSequence = favoriteButtonClicked.asObservable().withLatestFrom(nowFavorite)
            .flatMap { isFavorite -> Observable<Bool> in
                nowFavorite.accept(!isFavorite)
                return dataStore.save(liked: !isFavorite, for: repository.id).map { _ in !isFavorite }
            }
        
        self.isfavorite = Observable.merge(firstStatus, likeSequence)
            .map { $0 ? "⭐" : "☆" }
            .asDriver(onErrorDriveWith: .empty())
        
        self.estimatedProgress = webViewEstimatedProgress
            .asDriver(onErrorDriveWith: .empty())
            .compactMap { $0 }
            .do(onNext: { progress in
                print("progress bar: ", progress)
            })
    }
}
