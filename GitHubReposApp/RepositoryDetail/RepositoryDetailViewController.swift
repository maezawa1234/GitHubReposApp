import UIKit
import WebKit
import RxSwift
import RxCocoa

class RepositoryDetailViewController: UIViewController {
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var webView: WKWebView!
    
    private let repository: Repository
    private let disposeBag = DisposeBag()
    
    init?(coder: NSCoder, repository: Repository) {
        self.repository = repository
        
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        setup()
        binding()
    }
    
    private func setup() {
        self.navigationItem.title = repository.name
        let request = URLRequest(url: repository.htmlURL)
        webView.load(request)
    }
    
    private func binding() {
        webView.rx.observe(Double.self, #keyPath(WKWebView.estimatedProgress))
            .flatMap { estimatedProgress -> Observable<Double> in
                estimatedProgress.map(Observable.just) ?? .empty()
            }
            .bind(to: setProgress)
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
