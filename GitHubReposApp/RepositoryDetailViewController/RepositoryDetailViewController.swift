import UIKit
import WebKit

class RepositoryDetailViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    
    private let repository: Repository
    
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
    }
    
    private func setup() {
        self.navigationItem.title = repository.name
        
        let request = URLRequest(url: repository.htmlURL)
        webView.load(request)
    }
}
