import UIKit

struct ItemService: Codable {
    var items: [ImageItem]
}

struct ImageItem: Codable, Equatable {
    let title: String?
    let imageURL: URL
    let imageInfo: ImageInfo?
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case imageURL = "link"
        case imageInfo = "image"
    }
    
    struct ImageInfo: Codable {
        let width: CGFloat?
        let height: CGFloat?
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.title == rhs.title && lhs.imageURL == rhs.imageURL
    }
}


// 개선할만한 사항 : imageItems를 따로 다루는 Json파일을 유지
class ImageManager {
    
    let imageCache = NSCache<NSURL, NSData>()
    var imageItems = [ImageItem]()
    
    func saveImage(imageItem: ImageItem) {
        if let data = getCachedImage(url: imageItem.imageURL) {
            Storage.store(data, to: .documents, as: imageItem.title!)
        }
    }

    func removeImage(imageItem: ImageItem) {
        removeCachedImage(url: imageItem.imageURL)
        imageItems = imageItems.filter({ $0 != imageItem })
        Storage.remove(fileName: imageItem.title!, from: .documents)
    }
    
    func retrieveImageItems() {
        imageItems = []
        let urls = Storage.fileUrls
        for url in urls {
            let title = url.lastPathComponent
            let item = ImageItem(title: title, imageURL: url, imageInfo: nil)
            imageItems.append(item)
        }
    }
    
    func getImage(from url: URL) -> Data? {
        let fileName = url.lastPathComponent
        let imageData = Storage.retrive(fileName: fileName, from: .documents)
        self.cacheImage(url: url, imageData: imageData!)
        return imageData!
    }
    
    func cacheImage(url: URL, imageData: Data) {
        let NSUrl = NSURL(string: url.absoluteString)!
        imageCache.setObject(imageData as NSData, forKey: NSUrl)
    }
    
    func getCachedImage(url: URL) -> Data? {
        let NSUrl = NSURL(string: url.absoluteString)!
        return imageCache.object(forKey: NSUrl) as Data?
    }
    
    func removeCachedImage(url: URL) {
        let NSUrl = NSURL(string: url.absoluteString)!
        imageCache.removeObject(forKey: NSUrl)
    }
    
    func removeAllCachedImage() {
        imageCache.removeAllObjects()
    }
}
