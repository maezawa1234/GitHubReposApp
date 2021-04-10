import RxSwift
import RxCocoa
import RxDataSources

class UserReposViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private let indicator = UIActivityIndicatorView()
    
    private let favoriteButtonClicked: PublishRelay<(indexPath: IndexPath, repoStatus: RepoStatus, isFavorite: Bool)> = PublishRelay()
    
    private let disposeBag = DisposeBag()
    
    var user: User!
    
    private lazy var viewModel = UserReposViewModel(
        user: user,
        favoriteButtonClicked: favoriteButtonClicked.asDriver(onErrorDriveWith: .empty()),
        dependencies: (
            wireFrame: DefaultWireframe.shared,
            model: UserReposModel(),
            dataStore: UserDefaultsDataStore(userDefaults: UserDefaults.standard))
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        binding()
    }
    
    private func setup() {
        //Configure navigationBar
        self.navigationItem.title = "\(user.login)'s repositories"
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
        
        viewModel.sections
            .drive(onNext:{ sections in
                let a = sections[0].items.map { $0.isFavorite }
                print(a)
            })
            .disposed(by: disposeBag)
        
        viewModel.listIsEmpty
            .drive(setEmpty)
            .disposed(by: disposeBag)
        
        viewModel.fetchingRepos
            .drive(indicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        /*
        viewModel.updateCell
            .drive(onNext: { indexPath in
                let cell = self.tableView.cellForRow(at: indexPath) as! ReposCell
                cell.toggle()
            })
            .disposed(by: disposeBag)
 */
        
        favoriteButtonClicked.asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { row in
                print("favorite button tapped at: ", row)
            })
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
                print("YYYYYYYYYYYYYYYYYYYYY", repoStatus.isFavorite)
                cell.configure(with: repoStatus.repo, _isLiked: repoStatus.isFavorite)
                //print("cell at indexPath: \(indexPath) isLiked: \(repoStatus.isFavorite)")
                
                cell.favoriteButton.rx.tap.asDriver()
                    .drive(onNext: {
                        //print("isFavorite:", cell.isFavorite)
                        cell.isLiked.toggle()
                        print("GGGGGGGGGGGGGGGGG", repoStatus.isFavorite)
                        self.favoriteButtonClicked.accept((indexPath: indexPath, repoStatus: repoStatus, isFavorite: cell.isLiked))
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
}

