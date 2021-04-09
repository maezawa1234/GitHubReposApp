import UIKit

extension UITableView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .lightGray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 20)
        
        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }
    
    func restore() {
        self.backgroundView = nil
    }
}

public enum UniqueStrategy {
    case ignoreNewOne
    case replaceByNewOne
    case removeOldOne
}

public extension Array where Element: Equatable {
    func unique(resolve: (Element, Element) -> UniqueStrategy) -> [Element] {
        return reduce(into: []) { result, newOne in
            
            switch result.firstIndex(of: newOne) {
            case .none:
                result.append(newOne)
            case let prevIndex?:
                let prev = result[prevIndex]
                
                switch resolve(prev, newOne) {
                case .ignoreNewOne:
                    ()
                case .replaceByNewOne:
                    result[prevIndex] = newOne
                case .removeOldOne:
                    result.remove(at: prevIndex)
                    result.append(newOne)
                }
            }
        }
    }
}







