//
//  Cat.swift
//  RxSwift-Tutorial-2
//
//  Created by Sam Sung on 2023/06/18.
//

import Foundation

// MARK: - CatElement
struct CatElement: Codable {
    let url: String?
}

typealias Cat = [CatElement]
