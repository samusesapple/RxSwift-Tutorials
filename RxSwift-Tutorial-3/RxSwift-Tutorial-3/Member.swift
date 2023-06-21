//
//  Member.swift
//  RxSwift-Tutorial-3
//
//  Created by Sam Sung on 2023/06/21.
//

import Foundation

struct Member: Decodable {
    let id: Int
    let name: String
    let avatar: String
    let job: String
    let age: Int
}
