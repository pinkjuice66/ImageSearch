import Foundation


public class Storage {
    
    static var fileUrls: [URL] {
        let url = Directory.documents.url
        let urls = try! FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
        return urls
    }
    
    enum Directory {
        case documents
        case caches
        
        var url: URL {
            let path : FileManager.SearchPathDirectory
            switch self {
            case .documents:
                path = .documentDirectory
            case .caches:
                path = .cachesDirectory
            }
            return FileManager.default.urls(for: path, in: .userDomainMask).first!
        }
    }
    
    static func store(_ data: Data, to directory: Directory, as fileName: String)  {
        let url = directory.url.appendingPathComponent(fileName, isDirectory: false)
        
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    static func retrive(fileName: String, from directory: Directory) -> Data? {
        let url = directory.url.appendingPathComponent(fileName, isDirectory: false)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        guard let data = FileManager.default.contents(atPath: url.path) else { return nil }

        return data
    }
    
    static func remove(fileName: String, from directory: Directory)  {
        let url = directory.url.appendingPathComponent(fileName, isDirectory: false)
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        
        do {
            try FileManager.default.removeItem(at: url)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
