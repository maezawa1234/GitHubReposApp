import UIKit

class UserCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.layer.cornerRadius = 8
            containerView.layer.borderWidth = 1
            containerView.layer.borderColor = UIColor.lightGray.cgColor
            containerView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    static var identifier: String { "UserCell" }
    static var nib: UINib { UINib(nibName: identifier, bundle: nil) }
    
    private var task: URLSessionTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        task?.cancel()
        task = nil
        iconImageView.image = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with user: UserCellData) {
        self.userNameLabel.text = user.login
        
        if let cachedImage = ImageCache.shared.object(forKey: user.avatarURL as AnyObject) {
            self.iconImageView.image = cachedImage
            return
        }
        
        task = {
            let url = user.avatarURL
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let imageData = data else { return }
                DispatchQueue.global().async { [weak self] in
                    guard let image = UIImage(data: imageData) else { return }
                    DispatchQueue.main.async {
                        self?.iconImageView?.image = image
                        self?.setNeedsLayout()
                        ImageCache.shared.setObject(image, forKey: url as AnyObject)
                    }
                }
            }
            task.resume()
            return task
        }()
    }
}


