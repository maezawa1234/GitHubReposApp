import RxSwift
import RxCocoa
import RxDataSources

class FavoriteReposViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    private let favoriteButtonClicked: PublishRelay<(indexPath: IndexPath, repoStatus: RepoStatus)> = PublishRelay()
    
    private let disposeBag = DisposeBag()
    
    private lazy var viewModel = FavoriteReposViewModel(
        input: (
            cellSelected: self.tableView.rx.itemSelected.asDriver(),
            favoriteButtonClicked: self.favoriteButtonClicked.asDriver(onErrorDriveWith: .empty()),
            viewWillAppear: self.rx.viewWillAppear
        ),
        dependencies: (
            wireFrame: DefaultWireframe.shared,
            dataStore: UserDefaultsDataStore(userDefaults: UserDefaults.standard)
        )
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        binding()
    }
    
    private func setup() {
        // Configure navigetionBar
        self.navigationItem.title = "Favorite Repositories"
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.4, green: 0.4, blue: 1.0, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        //Configure tableView
        tableView.sectionHeaderHeight = .zero
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(ReposCell.nib, forCellReuseIdentifier: ReposCell.identifier)
    }
    
    private func binding() {
        viewModel.sections
            .drive(tableView.rx.items(dataSource: self.configureDataSource()))
            .disposed(by: disposeBag)
        
        viewModel.listIsEmpty
            .drive(setEmpty)
            .disposed(by: disposeBag)
        
        viewModel.transitionToRepoDetailView
            .drive(transitionToRepoDetailView)
            .disposed(by: disposeBag)
    }
    
    private func configureDataSource() -> RxTableViewSectionedAnimatedDataSource<UserReposSectionModel> {
        let dataSource = RxTableViewSectionedAnimatedDataSource<UserReposSectionModel>(
            animationConfiguration: AnimationConfiguration(
                insertAnimation: .right,
                reloadAnimation: .automatic,
                deleteAnimation: .fade
            ),
            configureCell: { (_, tableView, indexPath, repoStatus) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReposCell") as! ReposCell
                cell.configure(with: repoStatus.repo, isFavorite: repoStatus.isFavorite)
                
                cell.favoriteButton.rx.tap.asDriver()
                    .drive(onNext: {
                        self.favoriteButtonClicked.accept((indexPath: indexPath, repoStatus: repoStatus))
                    })
                    .disposed(by: cell.disposeBag)
                
                return cell
            },
            titleForHeaderInSection: { dataSource, sectionIndex in return dataSource[sectionIndex].header },
            canEditRowAtIndexPath: { (_, _) in false },
            canMoveRowAtIndexPath: { (_, _) in false }
        )
        return dataSource
    }
}

private extension FavoriteReposViewController {
    var setEmpty: Binder<Bool> {
        return Binder(self) { me, isEmpty in
            if isEmpty {
                let message = "There is no favorite repositories.\n\nPlease register your favorite one!"
                me.tableView.setEmptyMessage(message)
            } else {
                me.tableView.restore()
            }
        }
    }
    
    var transitionToRepoDetailView: Binder<Repository> {
        return Binder(self) { me, repo in
            let repoDetailVC = UIStoryboard(name: "RepositoryDetail", bundle: nil)
                .instantiateViewController(identifier: "RepositoryDetailViewController") { coder in
                    RepositoryDetailViewController(coder: coder, repository: repo)
                }
            self.navigationController?.pushViewController(repoDetailVC, animated: true)
        }
    }
}
