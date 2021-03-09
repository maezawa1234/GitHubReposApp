import RxSwift
import RxCocoa
import RxDataSources

class SearchUserViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalCountLabel: UILabel!
    private let closeButton = UIBarButtonItem(systemItem: .close)
    
    private let disposeBag = DisposeBag()
    
    private lazy var viewModel = SearchUserViewModel(
        input: (
            searchBarText: searchBar.rx.text.orEmpty.asDriver(),
            searchButtonClicked: searchBar.rx.searchButtonClicked.asSignal(),
            itemSelected: tableView.rx.itemSelected.asDriver()),
        dependency: (
            wireFrame: DefaultWireframe.shared,
            model: SearchUserModel()
        )
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        binding()
    }
    
    private func setup() {
        // Configure navigetionBar
        self.navigationItem.title = "Search User"
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.4, green: 0.4, blue: 1.0, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        //Configure searchBar
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 35))
        toolbar.setItems([closeButton], animated: true)
        searchBar.searchTextField.inputAccessoryView = toolbar
        //Configure tableView
        tableView.sectionHeaderHeight = .zero
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
    }
    
    private func binding() {
        viewModel.sections
            .drive(tableView.rx.items(dataSource: Self.configureDataSource()))
            .disposed(by: disposeBag)
        
        viewModel.transitionToReposView
            .drive(transitionToUserReposView)
            .disposed(by: disposeBag)
        
        viewModel.listIsEmpty
            .drive(setEmpty)
            .disposed(by: disposeBag)
        
        viewModel.totalCount
            .drive(totalCountText)
            .disposed(by: disposeBag)
        
        closeButton.rx.tap.asSignal()
            .emit(onNext: { _ in
                self.view.endEditing(true)
            })
            .disposed(by: disposeBag)
    }
    
    private static func configureDataSource() -> RxTableViewSectionedAnimatedDataSource<SearchUserSectionModel> {
        let dataSource = RxTableViewSectionedAnimatedDataSource<SearchUserSectionModel>(
            animationConfiguration: AnimationConfiguration(
                insertAnimation: .right,
                reloadAnimation: .automatic,
                deleteAnimation: .automatic
            ),
            configureCell: { (_, tableView, indexPath, user) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as! UserCell
                cell.configure(with: user)
                return cell
            },
            titleForHeaderInSection: { dataSource, sectionIndex in return dataSource[sectionIndex].header },
            canEditRowAtIndexPath: { (_, _) in false },
            canMoveRowAtIndexPath: { (_, _) in false }
        )
        return dataSource
    }
}

extension SearchUserViewController {
    private var setEmpty: Binder<Bool> {
        return Binder(self) { me, isEmpty in
            if isEmpty {
                me.tableView.setEmptyMessage("no user")
            } else {
                me.tableView.restore()
            }
        }
    }
    
    private var totalCountText: Binder<Int> {
        return Binder(self) { me, count in
            me.totalCountLabel.isHidden = false
            me.totalCountLabel.text = "検索件数: \(count)"
        }
    }
    
    private var transitionToUserReposView: Binder<User> {
        return Binder(self) { me, user in
            let userReposVC = UIStoryboard(name: "UserRepos", bundle: nil)
                .instantiateViewController(identifier: "UserReposViewController") as! UserReposViewController
            userReposVC.user = user
            me.navigationController?.pushViewController(userReposVC, animated: true)
        }
    }
}
 

