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
    
    private var isLiked = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var favoriteButtonClickedTrigger: PublishRelay<Int>!
    
    func configure(with repos: Repository, isLiked: Bool) {
        nameLabel.text = repos.name
        descriptionLabel.text = repos.description
        languageLabel.text = repos.language
        starLabel.text = "★ \(repos.stargazersCount)"
        self.isLiked = isLiked
    }
    
    @IBAction func clickedFavoriteButton(_ sender: Any) {
        self.isLiked.toggle()
        self.favoriteButton.setTitle(isLiked ? "⭐" : "☆", for: .normal)
        self.favoriteButtonClickedTrigger.accept(self.tag)
    }
}
