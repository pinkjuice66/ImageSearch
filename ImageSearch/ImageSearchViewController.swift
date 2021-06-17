import UIKit

class ImageSearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let imageManager = ImageManager()
    var imageRequests = [URL]()    // 셀을 return 할 때 이미지가 아직 도착안한 url들
    var prefetchingRequests = [URL]()    // 네트워크에 image data를 미리 requset한 url들
    let tapGR = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 250
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        tableView.delegate = self
        tableView.register(ImageCell.self, forCellReuseIdentifier: "ImageCell")
        searchBar.delegate = self
        tapGR.delegate = self
        self.view.addGestureRecognizer(tapGR)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if #available(iOS 13.0, *) {
            guard let targetVC = segue.destination as?
                    DetailImageViewController else { return }
            let indexPath = sender as? IndexPath
            let idx = (indexPath?.row)!
            guard let cell = tableView.cellForRow(at: indexPath!) as? ImageCell else { return }
            let image = cell.imagePresentation.image
            targetVC.image = image
            targetVC.titleText = self.imageManager.imageItems[idx].title
        } else {
            // Fallback on earlier versions
        }
    }
}

extension ImageSearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageManager.imageItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell") as? ImageCell else { fatalError() }
        cell.titleLabel.text = imageManager.imageItems[indexPath.row].title
        let item = imageManager.imageItems[indexPath.row]
        let width = UIScreen.main.bounds.width - 40
        let ratio = (item.imageInfo?.height)! / (item.imageInfo?.width)!
        let height = ratio * width
        cell.imageHeight.constant = height
        
        cell.buttonTapHandler = {
            self.imageManager.saveImage(imageItem: item)
        }
        
        // 이미지 데이터가 캐시에 있으면 가져옴
        if let imageData = imageManager.getCachedImage(url: item.imageURL) {
            cell.imagePresentation.image = UIImage(data: imageData)
            return cell
        } else { // 캐시에 없다면
            // DataSourcePrefetching에서 이미지를 이미 요청했다면
            if prefetchingRequests.contains(item.imageURL) {
                imageRequests.append(item.imageURL)
            } else {
                // DataSourcePrefetching에서 이미지를 아직 요청하지 않았다면
                DispatchQueue.global().async {
                    SearchAPI.getImage(from: item.imageURL) { imageData in
                        guard let imageData = imageData else { return }
                        self.imageManager.cacheImage(url: item.imageURL, imageData: imageData)
                        DispatchQueue.main.async {
                            cell.imagePresentation.image = UIImage(data: imageData)
                        }
                    }
                }
            }
            return cell
        }
    }
}

// 시나리오1 : prefetching을 하고 데이터를 가져온 경우 (o)
// 시나리오2 : prefetching을 했는데 데이터를 가져오는 중인 경우 (*)
// 시나리오3 : prefetching을 하지 않은 경우 (o)
extension ImageSearchViewController: UITableViewDataSourcePrefetching {

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let idx = indexPath.row
            let url = imageManager.imageItems[idx].imageURL
            prefetchingRequests.append(url)
            SearchAPI.getImage(from: url) { imageData in
                guard let imageData = imageData else { return }
                self.prefetchingRequests = self.prefetchingRequests.filter({$0 != url})
                self.imageManager.cacheImage(url: url, imageData: imageData)
                // 셀이 이미지가 도착하기를 기다리고 있는 경우 --> 시나리오2
                if self.imageRequests.contains(url) {
                    let items = self.imageManager.imageItems.enumerated().filter({ $0.element.imageURL == url })
                    self.imageRequests = self.imageRequests.filter{ $0 != url }
                    DispatchQueue.main.async {
                        for item in items {
                            guard let cell = tableView.cellForRow(at: IndexPath(row: item.offset, section: 0)) as? ImageCell else { continue }
                            // 셀이 현재 사용자 화면에 표시되고있는 경우에만 이미지를 바꾼다.
                            if self.tableView.visibleCells.contains(cell) {
                                cell.imagePresentation.image = UIImage(data: imageData)
                            }
                        }
                    }
                }
            }
        }
    }
}

extension ImageSearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detailImageSegue", sender: indexPath)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension ImageSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let term = searchBar.text, term != "" {
            self.imageManager.imageItems = []
            self.tableView.reloadData()
            self.imageManager.removeAllCachedImage()
            SearchAPI.searchTerm(term) { itemService in
                guard let items = itemService?.items else { return }
                DispatchQueue.main.async {
                    self.imageManager.imageItems = items
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        resignFirstResponder()
    }
}

extension ImageSearchViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive event: UIEvent) -> Bool {
        if self.searchBar.isFirstResponder {
            self.searchBar.resignFirstResponder()
            return true
        }
        return false
    }
}





