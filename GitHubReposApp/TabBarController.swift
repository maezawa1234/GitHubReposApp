import UIKit

class TabBarController: UITabBarController {
    enum ViewControllers {
        case search
    }
    
    let vcArray: [ViewControllers] = [.search]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UITabBar.appearance().barTintColor = UIColor(red: 0.6, green: 0.6, blue: 1.0, alpha: 1.0)
        UITabBar.appearance().tintColor = UIColor.white
        
        var myTabs: [UIViewController] = []
        var tabVC: UIViewController!
        
        for (i, vc) in vcArray.enumerated() {
            switch vc {
            case .search:
                let searchVC = UIStoryboard(name: "SearchUser", bundle: nil)
                    .instantiateViewController(identifier: "SearchUserViewController") as! SearchUserViewController
                tabVC = searchVC
                tabVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: i)
            }
            //各ビューにナビゲーションコントローラを追加
            let nc = UINavigationController(rootViewController: tabVC)
            myTabs.append(nc)
        }
        self.setViewControllers(myTabs, animated: false)
    }
}
