import UIKit

class StoredImageViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    let imageManager = ImageManager()
    let tapGR = UITapGestureRecognizer()
    var displayingImageItems: [ImageItem] {
        let text = searchBar.text?.lowercased()
        if text == "" { return imageManager.imageItems}
        else {
            let items = imageManager.imageItems.filter{ ($0.title?.lowercased().contains(text!))! }
            return items
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(tapGR)
        tapGR.delegate = self
        tableView.register(ImageCell.self, forCellReuseIdentifier: "ImageCell")
        tableView.dataSource = self
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageManager.retrieveImageItems()
        self.tableView.reloadData()
    }
}

extension StoredImageViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayingImageItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell") as? ImageCell else { return UITableViewCell() }
        let item = displayingImageItems[indexPath.row]
        if #available(iOS 13.0, *) {
            cell.button.setImage(UIImage(systemName: "minus"), for: .normal)
            cell.button.tintColor = .systemRed
        } else {
            // Fallback on earlier versions
        }
        cell.buttonTapHandler = {
            self.imageManager.removeImage(imageItem: item)
//            self.searchBar(self.searchBar, textDidChange: self.searchBar.text!)
            self.tableView.reloadData()
        }
        if let imageData = imageManager.getCachedImage(url: item.imageURL) {
            cell.imagePresentation.image = UIImage(data: imageData)
        } else {
            let imageData = imageManager.getImage(from: item.imageURL)
            cell.imagePresentation.image = UIImage(data: imageData!)
        }

        let width = UIScreen.main.bounds.width - 40
        let size = cell.imagePresentation.image?.size
        let ratio = (size?.height)! / (size?.width)!
        let height = ratio * width
        cell.imageHeight.constant = height
        cell.titleLabel.text = item.title
        
        return cell
    }
}

extension StoredImageViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
}

extension StoredImageViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive event: UIEvent) -> Bool {
        if self.searchBar.isFirstResponder {
            self.searchBar.resignFirstResponder()
            return true
        } else {
            return false
        }
    }
}



