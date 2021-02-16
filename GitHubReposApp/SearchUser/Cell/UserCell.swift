import UIKit

class UserCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.layer.cornerRadius = 8
            containerView.layer.masksToBounds = true
            containerView.layer.borderWidth = 1
            containerView.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    private var task: URLSessionTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
    
    func configure(with user: User) {
        self.userNameLabel.text = user.login
        
        task = {
            let url = user.avatarURL
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let imageData = data else {
                    return
                }

                DispatchQueue.global().async { [weak self] in
                    guard let image = UIImage(data: imageData) else {
                        return
                    }

                    DispatchQueue.main.async {
                        self?.iconImageView?.image = image
                        self?.setNeedsLayout()
                    }
                }
            }
            task.resume()
            return task
        }()
    }
}

