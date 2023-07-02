//
//  HistoryViewModel.swift
//  RxSwift-Tutorial-6
//
//  Created by Sam Sung on 2023/07/01.
//

import Foundation

final class HistoryViewModel: ViewModel {
    
    var account: BankAccount
    
    var history: [Transaction]
    
    init(viewModel: ViewModel) {
        self.account = viewModel.account
        self.history = viewModel.account.history
    }
}
