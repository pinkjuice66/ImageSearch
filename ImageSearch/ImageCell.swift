import UIKit

class ImageCell: UITableViewCell {
    
    static let reuseIdentifier = "ImageCell"
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    let imagePresentation: UIImageView = {
        let mainImageView = UIImageView()
        mainImageView.translatesAutoresizingMaskIntoConstraints = false
        mainImageView.contentMode = .scaleAspectFit
        return mainImageView
    }()
    let button: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "plus"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        button.tintColor = UIColor.systemBlue
        return button
    }()
    var buttonTapHandler : (() -> Void)?
    var imageHeight: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpConstraints()
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpConstraints()
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if #available(iOS 13.0, *) {
            self.imagePresentation.image = UIImage(systemName: "icloud.and.arrow.down")
        } else {
            // Fallback on earlier versions
        }
    }
    
    @objc
    func buttonTapped() {
        buttonTapHandler!()
    }
    
    func setUpConstraints() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(imagePresentation)
        contentView.addSubview(button)
        imageHeight = NSLayoutConstraint(item: imagePresentation, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 200)
        imageHeight.priority = UILayoutPriority(750)
        NSLayoutConstraint.activate(
            [ titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 50),
                titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -50),
                titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
                button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
                button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                button.widthAnchor.constraint(equalToConstant: 20),
                button.heightAnchor.constraint(equalToConstant: 20),
                imagePresentation.topAnchor.constraint(equalTo:     titleLabel.lastBaselineAnchor, constant: 15),
                imagePresentation.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                imagePresentation.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                imageHeight,
                imagePresentation.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
            ])
    }
}
