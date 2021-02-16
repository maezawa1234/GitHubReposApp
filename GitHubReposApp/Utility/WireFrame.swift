import RxSwift
import RxCocoa
import UIKit

enum RetryResult {
    case retry
    case cancel
}

protocol Wireframe {
    func promptFor<Action: CustomStringConvertible>(_ message: String, cancelAction: Action, actions: [Action]) -> Observable<Action>
}

class DefaultWireframe: Wireframe {
    static let shared = DefaultWireframe()
    
    private static func rootViewController() -> UIViewController {
        //return UIApplication.shared.keyWindow!.rootViewController!
        if #available(iOS 13.0, *) {
            let sceneDelegate = UIApplication.shared.connectedScenes
                .first!.delegate as! SceneDelegate
            return sceneDelegate.window!.rootViewController!
        // iOS12以前
        } else {
            return UIApplication.shared.keyWindow!.rootViewController!
        }
    }
    
    private static func topViewController() -> UIViewController {
        let sceneDelegate = UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate
        var vc = sceneDelegate.window!.rootViewController
        while vc?.presentedViewController != nil {
            vc = vc?.presentedViewController
        }
        return vc!
    }
    
    static func presentAlert(_ message: String) {
        let alertView = UIAlertController(title: "RxExample", message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .cancel) { _ in
        })
        rootViewController().present(alertView, animated: true, completion: nil)
    }
    
    func promptFor<Action : CustomStringConvertible>(_ message: String, cancelAction: Action, actions: [Action]) -> Observable<Action> {
        
        return Observable.create { observer in
            let alertView = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: cancelAction.description, style: .cancel) { _ in
                observer.on(.next(cancelAction))
            })
            
            for action in actions {
                alertView.addAction(UIAlertAction(title: action.description, style: .default) { _ in
                    observer.on(.next(action))
                })
            }
            
            //DefaultWireframe.rootViewController().present(alertView, animated: true, completion: nil)
            DefaultWireframe.topViewController().present(alertView, animated: true, completion: nil)
            
            return Disposables.create {
                alertView.dismiss(animated: false, completion: nil)
            }
        }
    }
}

extension RetryResult : CustomStringConvertible {
    var description: String {
        switch self {
        case .retry:
            return "Retry"
        case .cancel:
            return "Cancel"
        }
    }
}

extension UIApplication {
    // 最前面の画面を知るために用いる。
    class func keyWindowTopViewController(on controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return keyWindowTopViewController(on: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController,
           let selected = tabController.selectedViewController {
            return keyWindowTopViewController(on: selected)
        }
        if let presented = controller?.presentedViewController {
            return keyWindowTopViewController(on: presented)
        }
        return controller
    }
    
    // 最前面に画面を表示するために用いる。
    class func topViewController() -> UIViewController? {
        guard let rootViewController = UIApplication.shared.delegate?.window??.rootViewController else { return nil }
        var presentedViewController = rootViewController.presentedViewController
        if presentedViewController == nil {
            return rootViewController
        } else {
            while presentedViewController?.presentedViewController != nil {
                presentedViewController = presentedViewController?.presentedViewController
            }
            return presentedViewController
        }
    }
}




