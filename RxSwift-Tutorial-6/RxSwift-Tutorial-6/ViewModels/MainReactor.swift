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
    }
    
    /// Action about Input
    enum Mutation: Equatable {
        case currentBalanceDidChanged(Int)
    }
    
    /// Output
    struct State: Equatable {
        let currentBalance: Int
    }
    
    // MARK: - Initializer
    
    init(data: BankData) {
        self.account = data.account
        self.initialState = State(currentBalance: data.account.balance)
    }
    
    // MARK: - Bind
    
    func mutate(action: Action) -> Observable<Mutation> {
        return Observable.create { emitter in
            switch action {
            case .currentBalanceDidChanged(let newValue):
                emitter.onNext(.currentBalanceDidChanged(newValue))
            }
            return Disposables.create()
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case .currentBalanceDidChanged(let newValue):
            self.account.balance = newValue
            return State(currentBalance: newValue)
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

