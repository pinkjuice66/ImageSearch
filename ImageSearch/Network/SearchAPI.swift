import UIKit

class SearchAPI {
    
    static let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        return URLSession(configuration: configuration)}()
    
    static func searchTerm(_ term: String, completion : @escaping (ItemService?) -> Void ) {
        var urlComponents = URLComponents(string: "https://www.googleapis.com/customsearch/v1?key=AIzaSyC0jnzmCLjh-rfagMFM6EY_EPXDpd2i1kk&cx=f2e019b596a6a3b6b&imageType=photo&searchType=image")
        let termQuery = URLQueryItem(name: "q", value: term)
        urlComponents?.queryItems?.append(termQuery)
        let url = (urlComponents?.url)!
        
        let task = session.dataTask(with: url) { data, response, error in
            guard error == nil else {
                print(error?.localizedDescription)
                completion(nil)
                return
            }
            let status = response as? HTTPURLResponse
            guard (200...299).contains((status?.statusCode)!) else {
                print("status code : \(status?.statusCode) ")
                completion(nil)
                return
            }
            guard let itemService = parseToItemService(data!) else { return }
            completion(itemService)
        }
        task.resume()

    }

    static func getImage(from url : URL, completion : @escaping (UIImage?) -> Void ) {
        let task = session.dataTask(with: url) { data, response, error in
            guard error == nil else {
                print(error?.localizedDescription)
                completion(nil)
                return
            }
            let status = response as? HTTPURLResponse
            guard (200...299).contains((status?.statusCode)!) else {
                print("status code : \(status?.statusCode) ")
                completion(nil)
                return
            }
            let image = UIImage(data: data!)
            completion(image)
        }
        task.resume()
    }
    
    static func parseToItemService(_ data: Data) -> ItemService? {
        let decoder = JSONDecoder()
        do {
            let itemService = try decoder.decode(ItemService.self, from: data)
            return itemService
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
}

//func downsample(imageData: Data, for size: CGSize, scale:CGFloat) -> UIImage {
//        // dataBuffer가 즉각적으로 decoding되는 것을 막아줍니다.
//        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
//        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions) else { return UIImage() }
//        let maxDimensionInPixels = max(size.width, size.height) * scale
//        let downsampleOptions =
//            [kCGImageSourceCreateThumbnailFromImageAlways: true,
//             kCGImageSourceShouldCacheImmediately: true, //  thumbNail을 만들 때 decoding이 일어나도록 합니다.
//             kCGImageSourceCreateThumbnailWithTransform: true,
//             kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary
//        
//        // 위 옵션을 바탕으로 다운샘플링 된 `thumbnail`을 만듭니다.
//        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else { return UIImage() }
//        return UIImage(cgImage: downsampledImage)
//}


