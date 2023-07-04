//
//  MockViewMocel.swift
//  RxSwift-Tutorial-6
//
//  Created by Sam Sung on 2023/07/01.
//

import Foundation

final class MockData: BankData {
    var account: BankAccount
    
    init(account: BankAccount) {
        self.account = account
    }
}
