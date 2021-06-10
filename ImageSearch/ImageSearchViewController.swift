import UIKit

class ImageSearchViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var imageItems = [ImageItem]() {
        didSet {
            if imageItems.count < 5 { return }
            let idx = imageItems.count - 1
            let idxPath = IndexPath(row: idx, section: 0)
            DispatchQueue.main.async {
                if let cell = self.tableView.cellForRow(at: idxPath) {
                    if self.tableView.visibleCells.contains(cell) {
//                        self.tableView.reloadRows(at: [idxPath], with: .automatic)
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    var imageRequests = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 250
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        tableView.delegate = self
        tableView.register(ImageCell.self, forCellReuseIdentifier: "ImageCell")
        searchBar.delegate = self
    }

    @IBAction func test(_ sender: Any) {
        self.imageItems = []
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let storyborad = UIStoryboard(name: "Main", bundle: nil)
        if #available(iOS 13.0, *) {
            guard let targetVC = segue.destination as? DetailImageViewController else { return }
            let indexPath = sender as? IndexPath
            let idx = indexPath?.row
            targetVC.image = self.imageItems[idx!].image
            targetVC.titleText = self.imageItems[idx!].title
        } else {
            // Fallback on earlier versions
        }
    }
}

extension ImageSearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageItems.count + imageRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell") as? ImageCell else { fatalError() }
        if imageItems.count - 1 < indexPath.row {
            cell.titleLabel.text = "....."
            if #available(iOS 13.0, *) {
                cell.imagePresentation.image = UIImage(systemName: "icloud")
                cell.imageHeight.constant = 150
            } else {
                // Fallback on earlier versions
            }
            return cell
        }
        cell.titleLabel.text = imageItems[indexPath.row].title
        cell.imagePresentation.image = imageItems[indexPath.row].image

        let width = self.view.bounds.width - 40
        let ratio = (cell.imagePresentation.image?.size.height)! / (cell.imagePresentation.image?.size.width)!
        let height = ratio * width
        cell.imageHeight.constant = height
        print(indexPath.row)

        return cell
    }
}

extension ImageSearchViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let idx = indexPath.row
            if idx <= imageItems.count - 1 { continue }
            if self.imageRequests.isEmpty { return }
            
            let request = self.imageRequests.removeLast()
            SearchAPI.getImage(from: request.url) { image in
                let title = request.title ?? ""
                let imageItem = ImageItem(title: title, image: image)
                self.imageItems.append(imageItem)
            }
        }
    }
}

extension ImageSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detailImageSegue", sender: indexPath)
    }
}

extension ImageSearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.imageItems = []
        if let term = searchBar.text, term != "" {
            SearchAPI.searchTerm(term) { itemService in
                guard let items = itemService?.items else { return }

                self.imageRequests.append(contentsOf: items)
                for _ in 1...5 {
                    if self.imageRequests.isEmpty {
                        self.tableView.reloadData()
                        return
                    }
                    let item = self.imageRequests.removeLast()
                
                    SearchAPI.getImage(from: item.url) { image in
                        let title = item.title ?? ""
                        let imageItem = ImageItem(title: title, image: image)
                        self.imageItems.append(imageItem)
                        if self.imageItems.count == 5 {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        resignFirstResponder()
    }
}

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
    let addButton: UIButton = {
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
    var buttonTappedHandler : ((Bool) -> Void)?
    var imageHeight: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpConstraints()
    }
    
    func setUpConstraints() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(imagePresentation)
        contentView.addSubview(addButton)
        imageHeight = NSLayoutConstraint(item: imagePresentation, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 200)
        imageHeight.priority = UILayoutPriority(750)
        NSLayoutConstraint.activate(
            [ titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 50),
                titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -50),
                titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
                addButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
                addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                addButton.widthAnchor.constraint(equalToConstant: 20),
                addButton.heightAnchor.constraint(equalToConstant: 20),
                imagePresentation.topAnchor.constraint(equalTo:     titleLabel.lastBaselineAnchor, constant: 15),
                imagePresentation.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                imagePresentation.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                imageHeight,
                imagePresentation.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
            ])
    }
}



