import RxSwift
import RxCocoa
import RxDataSources

class UserReposViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private let indicator = UIActivityIndicatorView()
    
    private let favoriteButtonClicked: PublishRelay<IndexPath> = PublishRelay()
    
    private let disposeBag = DisposeBag()
    
    var user: User!

    private lazy var viewModel = UserReposViewModel(
        user: user,
        favoriteButtonClicked: favoriteButtonClicked.asDriver(onErrorDriveWith: .empty()),
        dependencies: (
            wireFrame: DefaultWireframe.shared,
            model: UserReposModel())
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
        
        viewModel.listIsEmpty
            .drive(setEmpty)
            .disposed(by: disposeBag)
        
        viewModel.fetchingRepos
            .drive(indicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
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
            configureCell: { (_, tableView, indexPath, repos) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReposCell") as! ReposCell
                
                cell.configure(with: repos, isLiked: false)
                
                cell.favoriteButton.rx.tap.asDriver()
                    .drive(onNext: {
                        self.favoriteButtonClicked.accept(indexPath)
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
 
