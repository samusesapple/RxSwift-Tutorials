//
//  CurrencyFormatter.swift
//  RxSwift-Tutorial-5
//
//  Created by Sam Sung on 2023/06/27.
//

import Foundation

struct Formatter {
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .currency
        formatter.currencyCode = "KRW"
        return formatter
    }()
}
