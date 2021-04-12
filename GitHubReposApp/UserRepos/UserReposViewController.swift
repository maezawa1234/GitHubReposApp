import RxSwift
import RxCocoa
import RxDataSources

class UserReposViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private let indicator = UIActivityIndicatorView()
    
    private let favoriteButtonClicked: PublishRelay<(indexPath: IndexPath, repoStatus: RepoStatus)> = PublishRelay()
    private let disposeBag = DisposeBag()
    
    var user: User!
    
    private lazy var viewModel = UserReposViewModel(
        user: user,
        input: (
            cellSelected: tableView.rx.itemSelected.asDriver(onErrorDriveWith: .empty()),
            favoriteButtonClicked: favoriteButtonClicked.asDriver(onErrorDriveWith: .empty()),
            viewWillAppear: self.rx.viewWillAppear
        ),
        dependencies: (
            wireFrame: DefaultWireframe.shared,
            webClient: WebAPIClient(),
            dataStore: UserDefaultsDataStore(userDefaults: UserDefaults.standard)
        )
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        binding()
    }
    
    private func setup() {
        //Configure navigationBar
        self.navigationItem.title = "\(user.login)'s Repositories"
        //Configure tableView
        tableView.sectionHeaderHeight = .zero
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(UINib(nibName: "ReposCell", bundle: nil), forCellReuseIdentifier: "ReposCell")
        //Configure indicator
        indicator.center = self.view.center
        indicator.style = .large
        indicator.hidesWhenStopped = true
        self.view.addSubview(indicator)
    }
    
    private func binding() {
        viewModel.sections
            .drive(tableView.rx.items(dataSource: self.configureDataSource())) 
            .disposed(by: disposeBag)
        
        viewModel.listIsEmpty
            .drive(setEmpty)
            .disposed(by: disposeBag)
        
        viewModel.fetchingRepos
            .drive(indicator.rx.isAnimating)
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

extension UserReposViewController {
    private var setEmpty: Binder<Bool> {
        return Binder(self) { me, isEmpty in
            if isEmpty {
                me.tableView.setEmptyMessage("no repos")
            } else {
                me.tableView.restore()
            }
        }
    }
    
    private var transitionToRepoDetailView: Binder<Repository> {
        return Binder(self) { me, repo in
            let repoDetailVC = UIStoryboard(name: "RepositoryDetail", bundle: nil)
                .instantiateViewController(identifier: "RepositoryDetailViewController") { coder in
                    RepositoryDetailViewController(coder: coder, repository: repo)
                }
            self.navigationController?.pushViewController(repoDetailVC, animated: true)
        }
    }
}

