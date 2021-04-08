import UIKit

class TabBarController: UITabBarController {
    enum ViewControllers {
        case search
        case favorite
    }
    let vcArray: [ViewControllers] = [.search, .favorite]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UITabBar.appearance().barTintColor = UIColor(red: 0.4, green: 0.4, blue: 1.0, alpha: 1.0)
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
                
            case .favorite:
                //FIXME: お気に入りVCのインスタンス化、未実装
                let favoriteVC = UIViewController()
                tabVC = favoriteVC
                tabVC.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: i)
            }
            let nc = UINavigationController(rootViewController: tabVC)
            myTabs.append(nc)
        }
        self.setViewControllers(myTabs, animated: false)
    }
}
