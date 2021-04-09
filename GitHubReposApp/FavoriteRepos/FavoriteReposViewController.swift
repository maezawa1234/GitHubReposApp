import RxSwift
import RxCocoa

class FavoriteReposViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private let disposeBag = DisposeBag()
    
    private lazy var viewModel = FavoriteReposViewModel()
    
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
        //tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
    }
    
    private func binding() {
        
    }
}
