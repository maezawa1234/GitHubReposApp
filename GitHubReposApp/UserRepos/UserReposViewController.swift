import RxSwift
import RxCocoa
import RxDataSources

class UserReposViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    
    private let disposeBag = DisposeBag()
    
    var user: User!

    private lazy var viewModel = UserReposViewModel(
        userName: user.login,
        viewDidAppear: self.rx.viewDidAppear,
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
        
        //Configure tableView
        tableView.sectionHeaderHeight = .zero
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(UINib(nibName: "ReposCell", bundle: nil), forCellReuseIdentifier: "ReposCell")
        
    }
    
    private func binding() {
        viewModel.sections
            .drive(tableView.rx.items(dataSource: Self.configureDataSource()))
            .disposed(by: disposeBag)
    }
    
    private static func configureDataSource() -> RxTableViewSectionedAnimatedDataSource<UserReposSectionModel> {
        let dataSource = RxTableViewSectionedAnimatedDataSource<UserReposSectionModel>(
            animationConfiguration: AnimationConfiguration(
                insertAnimation: .right,
                reloadAnimation: .automatic,
                deleteAnimation: .fade
            ),
            configureCell: { (_, tableView, indexPath, repos) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReposCell") as! ReposCell
                cell.configure(with: repos)
                return cell
            },
            titleForHeaderInSection: { dataSource, sectionIndex in return dataSource[sectionIndex].header },
            canEditRowAtIndexPath: { (_, _) in false },
            canMoveRowAtIndexPath: { (_, _) in false }
        )
        return dataSource
    }
}
