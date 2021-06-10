import UIKit

struct ItemService: Codable {
    var items: [Item]
}

struct Image: Codable{
    let width : Int
    let height : Int
}

struct Item: Codable {
    let title: String?
    let url: URL
    
    enum CodingKeys: String, CodingKey {
        case title
        case url = "link"
    }
}

struct ImageItem {
    let title : String
    let image : UIImage?
}
