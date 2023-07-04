//
//  HistoryViewModel.swift
//  RxSwift-Tutorial-6
//
//  Created by Sam Sung on 2023/07/01.
//

import Foundation

final class HistoryViewModel: BankData {
    
    var account: BankAccount
    
    var history: [Transaction]
    
    init(data: BankData) {
        self.account = data.account
        self.history = data.account.history
    }
}
