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
        case historyButtonTapped
        case actionButtonTapped
        case currentBalanceDidChanged(Int)
    }
    
    /// Action about Input
    enum Mutation: Equatable {
        case presentHistoryVC
        case presentTransactionVC
        case currentBalanceDidChanged(Int)
    }
    
    /// Output
    struct State: Equatable {
        let currentBalance: Int
        let needToShowHistory: Bool
        let needToShowTransaction: Bool
    }
    
    // MARK: - Initializer
    
    init(data: BankData) {
        self.account = data.account
        self.initialState = State(currentBalance: data.account.balance,
                                  needToShowHistory: false,
                                  needToShowTransaction: false)
    }
    
    // MARK: - Bind
    
    func mutate(action: Action) -> Observable<Mutation> {
        return Observable.create { emitter in
            switch action {
            case .historyButtonTapped:
                emitter.onNext(.presentHistoryVC)
            case .actionButtonTapped:
                emitter.onNext(.presentTransactionVC)
            case .currentBalanceDidChanged(let int):
                emitter.onNext(.currentBalanceDidChanged(int))
            }
            return Disposables.create()
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case .presentHistoryVC:
            return State(currentBalance: state.currentBalance,
                         needToShowHistory: true,
                         needToShowTransaction: false)
        case .presentTransactionVC:
            return State(currentBalance: state.currentBalance,
                         needToShowHistory: false,
                         needToShowTransaction: true)
        case .currentBalanceDidChanged(let int):
            return State(currentBalance: int,
                         needToShowHistory: false,
                         needToShowTransaction: false)
        }
    }
    
    // MARK: - Methods
    
    var historyViewModel: BankData {
        return self
    }
    
    var transactionViewModel: BankData {
        return self
    }
}

