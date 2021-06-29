import RxSwift
import RxCocoa
import RxDataSources

class SearchUserViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var totalCountLabel: UILabel!
    private lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.center = self.view.center
        indicator.style = .large
        indicator.hidesWhenStopped = true
        return indicator
    }()
    private let closeButton = UIBarButtonItem(systemItem: .close)
    
    private lazy var loadingFooterView: UIView = {
        let screenWidth = UIScreen.main.bounds.size.width
        return LoadingFooterView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 100))
    }()
    
    private let disposeBag = DisposeBag()
    
    private lazy var viewModel: SearchUserViewModelType = SearchUserViewModel(model: WebAPIClient.shared)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        binding()
    }
    
    private func setupView() {
        // Configure navigetionBar
        self.navigationItem.title = "Search User"
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.4, green: 0.4, blue: 1.0, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.alpha = 1
        //Configure searchBar
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 35))
        toolbar.setItems([closeButton], animated: true)
        searchBar.searchTextField.inputAccessoryView = toolbar
        //Configure tableView
        tableView.sectionHeaderHeight = .zero
        tableView.tableFooterView = loadingFooterView
        tableView.register(UserCell.nib, forCellReuseIdentifier: UserCell.identifier)
        //Configure activityIndicator
        self.view.addSubview(indicator)
    }
    
    private func binding() {
        searchBar.rx.text.orEmpty.asObservable()
            .bind(to: viewModel.inputs.searchBarText)
            .disposed(by: disposeBag)
        
        searchBar.rx.searchButtonClicked.asSignal()
            .emit(to: viewModel.inputs.searchButtonClicked)
            .disposed(by: disposeBag)
        
        searchBar.rx.textDidBeginEditing.asSignal()
            .emit(to: viewModel.inputs.searchBarDidBeginEditing)
            .disposed(by: disposeBag)
        
        Signal.merge(closeButton.rx.tap.asSignal(), searchBar.rx.cancelButtonClicked.asSignal())
            .emit(to: viewModel.inputs.closeButtonClicked)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected.asObservable()
            .bind(to: viewModel.inputs.itemSelected)
            .disposed(by: disposeBag)
        
        tableView.rx.reachedBottom.asSignal()
            .emit(to: viewModel.inputs.loadAdditionalUsers)
            .disposed(by: disposeBag)
        
        viewModel.output.userSections
            .drive(tableView.rx.items(dataSource: self.configureDataSource()))
            .disposed(by: disposeBag)
        
        viewModel.output.transitionToReposView
            .drive(transitionToUserReposView)
            .disposed(by: disposeBag)
       
        viewModel.output.isFetching
            .drive(indicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.output.isSearchFieldEditing
            .drive(refrectEditing)
            .disposed(by: disposeBag)
        
        viewModel.output.totalCount
            .drive(totalCountText)
            .disposed(by: disposeBag)
        
        viewModel.output.listIsEmpty
            .drive(setEmpty)
            .disposed(by: disposeBag)
        
        viewModel.output.isLoadingFooterHidden
            .drive(isVisibleLoadingFooterView)
            .disposed(by: disposeBag)
        
        viewModel.output.isErrorOccured
            .drive(showErrorAlertView)
            .disposed(by: disposeBag)
    }
    
    private func configureDataSource() -> RxTableViewSectionedAnimatedDataSource<SearchUserSectionModel> {
        let dataSource = RxTableViewSectionedAnimatedDataSource<SearchUserSectionModel>(
            animationConfiguration: AnimationConfiguration(
                insertAnimation: .automatic,
                reloadAnimation: .fade,
                deleteAnimation: .automatic
            ),
            configureCell: { (_, tableView, indexPath, userCellData) in
                let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier) as! UserCell
                cell.configure(with: userCellData)
                return cell
            },
            titleForHeaderInSection: { dataSource, sectionIndex in return dataSource[sectionIndex].header },
            canEditRowAtIndexPath: { (_, _) in false },
            canMoveRowAtIndexPath: { (_, _) in false }
        )
        return dataSource
    }
    
    private func isBottomEdge() -> Bool {
        return (tableView.contentSize.height - tableView.bounds.size.height - 350) <= tableView.contentOffset.y
    }
}

extension SearchUserViewController {
    private var refrectEditing: Binder<Bool> {
        return Binder(self) { me, isEditing in
            UIView.animate(withDuration: 0.3) {
                if isEditing {
                    self.view.backgroundColor = .black
                    self.tableView.isUserInteractionEnabled = false
                    self.tableView.alpha = 0.5
                    self.totalCountLabel.alpha = 0.5
                    self.searchBar.setShowsCancelButton(true, animated: true)
                } else {
                    self.view.backgroundColor = .white
                    self.searchBar.resignFirstResponder()
                    self.tableView.isUserInteractionEnabled = true
                    self.tableView.alpha = 1
                    self.totalCountLabel.alpha = 1
                    self.searchBar.setShowsCancelButton(false, animated: true)
                }
            }
        }
    }
    
    private var setEmpty: Binder<Bool> {
        return Binder(self) { me, isEmpty in
            if isEmpty {
                me.tableView.setEmptyMessage("no user")
            } else {
                me.tableView.restore()
            }
        }
    }
    
    private var isVisibleLoadingFooterView: Binder<Bool> {
        return Binder(self) { me, isVisible in
            print("footer isVisible now: ", isVisible)
            if isVisible {
                me.tableView.tableFooterView = me.loadingFooterView
            } else {
                me.tableView.tableFooterView = UIView(frame: .zero)
            }
        }
    }
    
    private var totalCountText: Binder<Int> {
        return Binder(self) { me, count in
            me.totalCountLabel.isHidden = false
            me.totalCountLabel.text = "  検索件数: \(count)"
        }
    }
    
    private var transitionToUserReposView: Binder<UserCellData> {
        return Binder(self) { me, user in
            let userReposVC = UIStoryboard(name: "UserRepos", bundle: nil)
                .instantiateViewController(identifier: "UserReposViewController") { coder in
                    UserReposViewController(coder: coder, user: user)
                }
            me.navigationController?.pushViewController(userReposVC, animated: true)
        }
    }
    
    private var showErrorAlertView: Binder<String> {
        return Binder(self) { me, message in
            me.showErrorAlert(title: nil, message: message)
        }
    }
}

extension SearchUserViewController: ShowAlert {}
