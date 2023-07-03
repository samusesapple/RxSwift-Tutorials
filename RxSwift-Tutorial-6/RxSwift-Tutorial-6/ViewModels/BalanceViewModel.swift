//
//  BalanceViewModel.swift
//  RxSwift-Tutorial-6
//
//  Created by Sam Sung on 2023/07/01.
//

import Foundation
import RxSwift
import ReactorKit

protocol ViewModel: AnyObject {
    var account: BankAccount { get set }
}

final class BalanceViewModel: ViewModel, Reactor {
    
    let initialState: State
    
    enum Action {
        case historyButtonTapped
        case actionButtonTapped
    }
    
    struct State {
        let currentBalance: Int
    }
    
    var account: BankAccount
    
    init(viewModel: ViewModel) {
        self.account = viewModel.account
        self.initialState = State(currentBalance: viewModel.account.balance)
    }
    
    var historyViewModel: ViewModel {
        return self
    }
    
    var transactionViewModel: ViewModel {
        return self
    }
}

