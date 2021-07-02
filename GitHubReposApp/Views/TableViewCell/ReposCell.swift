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
    
    static var identifier: String { "ReposCell" }
    static var nib: UINib { UINib(nibName: identifier, bundle: nil) }

    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.containerView.backgroundColor = .white
        self.disposeBag = DisposeBag()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        guard !highlighted else {
            containerView.backgroundColor = .systemGray5
            return
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.containerView.backgroundColor = .white
        }
    }
    
    func configure(with repos: Repository, isFavorite: Bool) {
        nameLabel.text = repos.name
        descriptionLabel.text = repos.description
        languageLabel.text = repos.language
        starLabel.text = "★ \(repos.stargazersCount)"
        favoriteButton.setTitle(isFavorite ? "⭐" : "☆", for: .normal)
    }
}
