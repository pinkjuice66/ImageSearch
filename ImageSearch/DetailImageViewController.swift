import UIKit

class DetailImageViewController: UIViewController {
    
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!
    
    var image: UIImage!
    var titleText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleLabel.text = titleText
        mainImageView.image = image
        let width = self.view.bounds.width
        let ratio = (mainImageView?.image?.size.height)! / (mainImageView?.image?.size.width)!
        let height = ratio * width
        imageHeightConstraint.constant = height
    }
}
