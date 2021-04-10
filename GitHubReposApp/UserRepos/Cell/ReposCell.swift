import RxSwift
import RxCocoa

class ReposCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.layer.cornerRadius = 8
            containerView.layer.masksToBounds = true
            containerView.layer.borderWidth = 1
            containerView.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var languageContainerView: UIView!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var starLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton! 
    
    var isFavorite: Bool {
        print(favoriteButton.titleLabel?.text)
        return favoriteButton.titleLabel?.text == "☆"
    }
    
    // Favorite state
    var isLiked: Bool!
    
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag()
    }
    
    func configure(with repos: Repository, _isLiked: Bool) {
        nameLabel.text = repos.name
        descriptionLabel.text = repos.description
        languageLabel.text = repos.language
        starLabel.text = "★ \(repos.stargazersCount)"
        self.isLiked = _isLiked
        self.favoriteButton.setTitle(self.isLiked ? "⭐" : "☆", for: .normal)
    }
    
    @IBAction func clickedFavoriteButton(_ sender: Any) {
        //self.favoriteButton.setTitle(self.isLiked ? "⭐" : "☆", for: .normal)
        //self.isLiked.toggle()
    }
    
    func toggle() {
        if self.favoriteButton.titleLabel?.text == "☆" {
            favoriteButton.setTitle("⭐", for: .normal)
        } else {
            favoriteButton.setTitle("☆", for: .normal)
        }
    }
}
