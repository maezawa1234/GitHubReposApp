import RxSwift
import RxCocoa
import RxDataSources

class FavoriteReposViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private let disposeBag = DisposeBag()
    
    private lazy var viewModel = FavoriteReposViewModel(
        dependencies: (
            wireFrame: DefaultWireframe.shared,
            dataStore: UserDefaultsDataStore(userDefaults: UserDefaults.standard
            )
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
        tableView.register(UINib(nibName: "ReposCell", bundle: nil), forCellReuseIdentifier: "ReposCell")
    }
    
    private func binding() {
        viewModel.sections
            .drive(tableView.rx.items(dataSource: self.configureDataSource()))
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
                cell.configure(with: repoStatus.repo, isLiked: repoStatus.isFavorite)
                print("cell at indexPath: \(indexPath) isLiked: \(repoStatus.isFavorite)")
                
                return cell
            },
            titleForHeaderInSection: { dataSource, sectionIndex in return dataSource[sectionIndex].header },
            canEditRowAtIndexPath: { (_, _) in false },
            canMoveRowAtIndexPath: { (_, _) in false }
        )
        return dataSource
    }
}
