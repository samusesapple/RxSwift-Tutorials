//
//  BalanceViewModel.swift
//  RxSwift-Tutorial-6
//
//  Created by Sam Sung on 2023/07/01.
//

import Foundation
import RxSwift

protocol BankViewModel {
    var account: BankAccount { get set }
}

class BalanceViewModel: BankViewModel {
    var account: BankAccount
    
    var balanceObservable: Observable<String>
    
    init(viewModel: BankViewModel) {
        self.account = viewModel.account
        self.balanceObservable = Observable.just("\(viewModel.account.balance)")
    }
    
    var historyViewModel: HistoryViewModel {
        return HistoryViewModel(viewModel: self)
    }
}

