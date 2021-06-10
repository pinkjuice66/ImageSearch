//
//  DetailImageViewController.swift
//  ImageSearch
//
//  Created by Jade on 2021/06/10.
//

import UIKit

class DetailImageViewController: UIViewController {
    
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!
    
    var titleText : String?
    var image : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let width = self.view.bounds.width
        let ratio = (image?.size.height)! / (image?.size.width)!
        let height = ratio * width
        imageHeightConstraint.constant = height
        
        titleLabel.text = titleText
        mainImageView.image = image
    }
}
