import WebKit
import RxSwift
import RxCocoa

class RepositoryDetailViewController: UIViewController {
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var webView: WKWebView!
    private let favoriteButton = UIBarButtonItem(title: "⭐", style: .plain, target: nil, action: nil)
    
    private let repository: Repository
    
    private let viewModel: RepositoryDetailViewModelType
    private let disposeBag = DisposeBag()
    
    init?(coder: NSCoder, repository: Repository) {
        self.repository = repository
        self.viewModel = RepositoryDetailViewModel(repository: repository)
        
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        setup()
        bind()
    }
    
    private func setup() {
        self.navigationItem.title = repository.name
        self.navigationItem.rightBarButtonItem = favoriteButton
        let request = URLRequest(url: repository.htmlURL)
        webView.load(request)
    }
    
    private func bind() {
        webView.rx.observe(Double.self, #keyPath(WKWebView.estimatedProgress))
            .bind(to: viewModel.input.webViewEstimatedProgress)
            .disposed(by: disposeBag)
        
        favoriteButton.rx.tap.asSignal()
            .emit(to: viewModel.input.favoriteButtonClicked)
            .disposed(by: disposeBag)
         
        viewModel.output.isfavorite
            .drive(favoriteButton.rx.title)
            .disposed(by: disposeBag)
        
        viewModel.output.estimatedProgress
            .drive(setProgress)
            .disposed(by: disposeBag) 
    }
}

extension RepositoryDetailViewController {
    private var setProgress: Binder<Double> {
        return Binder(self) { me, progress in
            UIView.animate(withDuration: 0.3) {
                let isShown = 0.0..<1.0 ~= progress
                me.progressView.alpha = isShown ? 1 : 0
                me.progressView.setProgress(Float(progress), animated: isShown)
            }
        }
    }
}
