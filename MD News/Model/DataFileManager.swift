//
//  DataFileManager.swift
//  MD News
//
//  Created by Иван Зайцев on 02.04.2022.
//

import Foundation

class DataFileManager {
    
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

    func loadArticleData() -> [ArticleData] {
        
        guard let path = dataFilePath,
              let data = try? Data(contentsOf: path) else { return [] }
        
        let decoder = PropertyListDecoder()
        
        do {
            let info = try decoder.decode([ArticleData].self, from: data)
            return info
        } catch {
            print("Error decoding profile data, \(error)")
            return []
        }
    }
    
}
