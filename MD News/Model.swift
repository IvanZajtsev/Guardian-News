//
//  Model.swift
//  MD News
//
//  Created by Иван Зайцев on 29.03.2022.
//

import Foundation

struct News: Codable {
    let response: Response?
}
struct Response: Codable {
    let results: [Article?]?
}

struct Article: Codable {
    let webTitle: String?
    let webUrl: String?
    let fields: Field?
}
struct Field: Codable{
    let body: String // 🅰️HTML
    let thumbnail: String?
    let trailText: String?
    
}


