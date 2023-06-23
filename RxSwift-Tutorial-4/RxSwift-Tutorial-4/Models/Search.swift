//
//  File.swift
//  RxSwift-Tutorial-4
//
//  Created by Sam Sung on 2023/06/23.
//

import Foundation

// MARK: - Search
struct Search: Codable {
    let lastBuildDate: String?
    let total, start, display: Int?
    let items: [Item]?
}

// MARK: - Item
struct Item: Codable {
    let title: String?
    let link: String?
    let description, bloggername, bloggerlink, postdate: String?
}
