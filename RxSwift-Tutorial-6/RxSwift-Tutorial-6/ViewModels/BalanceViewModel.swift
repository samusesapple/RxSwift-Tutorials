//
//  BalanceViewModel.swift
//  RxSwift-Tutorial-6
//
//  Created by Sam Sung on 2023/07/01.
//

import Foundation
import RxSwift

protocol ViewModel: AnyObject {
    var account: BankAccount { get set }
}

final class BalanceViewModel: ViewModel {
    
    var account: BankAccount
    
    var balanceObservable: Observable<String>
    
    init(viewModel: ViewModel) {
        self.account = viewModel.account
        self.balanceObservable = Observable.just("\(viewModel.account.balance)")
    }
    
    var historyViewModel: ViewModel {
        return self
    }
    
    var transactionViewModel: ViewModel {
        return self
    }
}

