import UIKit
import WebKit

class RepositoryDetailViewController: UIViewController {

    //FIXME: urlの初期化処理しっかり書きましょう
    var url: URL!
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let request = URLRequest(url: self.url)
        webView.load(request)
    }
}
