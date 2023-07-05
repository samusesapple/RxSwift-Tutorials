//
//  BalanceViewModel.swift
//  RxSwift-Tutorial-6
//
//  Created by Sam Sung on 2023/07/01.
//

import Foundation
import RxSwift
import ReactorKit

protocol BankData: AnyObject {
    var account: BankAccount { get set }
}

final class MainReactor: BankData, Reactor {
    
    let initialState: State
    
    var account: BankAccount
    
    /// Input
    enum Action: Equatable {
        case currentBalanceDidChanged(Int)
        case historyListDidUpdated([Transaction])
    }
    
    /// Action about Input
    enum Mutation: Equatable {
        case updateCurrentBalanceValue(Int)
        case updateHistoryList([Transaction])
    }
    
    /// Output
    struct State: Equatable {
        let currentBalance: Int
        let historyList: [Transaction]
    }
    
    // MARK: - Initializer
    
    init(data: BankData) {
        self.account = data.account
        self.initialState = State(currentBalance: data.account.balance,
                                  historyList: data.account.history)
    }
    
    // MARK: - Bind
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .currentBalanceDidChanged(let newValue):
            return Observable.just(.updateCurrentBalanceValue(newValue))
        case .historyListDidUpdated(let newHistoryList):
            return Observable.just(.updateHistoryList(newHistoryList))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case .updateCurrentBalanceValue(let newValue):
            self.account.balance = newValue
            return State(currentBalance: newValue,
                         historyList: state.historyList)
        case .updateHistoryList(let newHistoryList):
            self.account.history = newHistoryList
            return state
        }
    }
    
    // MARK: - Methods
    
    var historyViewModel: HistoryViewModel {
        return HistoryViewModel(data: self)
    }
    
    var transactionReactor: TransactionReactor {
        return TransactionReactor(data: self)
    }
}

