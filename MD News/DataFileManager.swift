//
//  DataFileManager.swift
//  MD News
//
//  Created by Иван Зайцев on 02.04.2022.
//

import Foundation

class DataFileManager {
    
//    static var shared = DataFileManager()
    enum Constants {
        static let nameOfDataFile = "Data.plist"
    }
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(Constants.nameOfDataFile)
    
    func saveArticleData(_ data: ArticleData) throws {
        var oldData = loadArticleData()
        oldData.append(data)
        let encoder = PropertyListEncoder()
        guard let path = dataFilePath else { return }
        
        let data = try encoder.encode(oldData)
        try data.write(to: path)
    }
//    func encodeNSAttribitedString(attributedString: NSAttributedString) -> Data {
//        //🅰️ эта функция будет throws???
//
//        do {
//            let htmlData = try attributedString.data(from: .init(location: 0, length: attributedString.length),
//                                                     documentAttributes: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue])
//            return htmlData
//            //            let htmlString = String(data: htmlData, encoding: .utf8) ?? ""
//            //            print(htmlString)
//        } catch {
//            print(error)
//            return Data()
//        }
//
//    }
    
    func loadArticleData() -> [ArticleData] {
        
        guard let path = dataFilePath,
              let data = try? Data(contentsOf: path) else { return [] }
        
        let decoder = PropertyListDecoder()
        
        //        let image = loadImageFromDocumentDirectory(nameOfImage: Constants.nameOfUserPictureFile) ?? UIImage()
        do {
            let info = try decoder.decode([ArticleData].self, from: data)
            return info
        } catch {
            print("Error decoding profile data, \(error)")
            return []
        }
    }
    
//    func decodeNSAttribitedString(from data: Data) -> NSAttributedString? {
//        //🅰️ эта функция будет throws???
//        do {
//            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
//        }
//        catch {
//            print(error)
//            return nil
//        }
//    }
}
//    private func saveImageToDocumentDirectory(imageData: Data?) throws {
//        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
//        let fileName = DataFileManager.Constants.nameOfUserPictureFile
//        let fileURL = documentsDirectory.appendingPathComponent(fileName)
//        if let data = imageData {
//
//            do {
//                try data.write(to: fileURL)
//                print("file saved")
//            }
//        }
//    }
//    private func loadImageFromDocumentDirectory(nameOfImage: String) -> UIImage? {
//
//        guard let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
//            return  UIImage(named: Constants.defaultPictureName)
//        }
//        let image = UIImage(contentsOfFile: directoryURL.appendingPathComponent(nameOfImage).path)
//        return image
//    }

