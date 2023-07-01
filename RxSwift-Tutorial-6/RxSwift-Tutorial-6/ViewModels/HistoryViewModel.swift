//
//  HistoryViewModel.swift
//  RxSwift-Tutorial-6
//
//  Created by Sam Sung on 2023/07/01.
//

import Foundation

class HistoryViewModel: BankViewModel {
    
    var account: BankAccount
    
    var history: [Transaction]
    
    init(viewModel: BankViewModel) {
        self.account = viewModel.account
        self.history = viewModel.account.history
    }
}
