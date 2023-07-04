//
//  TransactionViewModel.swift
//  RxSwift-Tutorial-6
//
//  Created by Sam Sung on 2023/07/02.
//

import Foundation
import ReactorKit

final class TransactionReactor: BankData, Reactor {
    
    let initialState: State
    
    var account: BankAccount
    
    private var disposeBag = DisposeBag()
    
    // Input
    /// view로부터 받는 action 정의
    enum Action: Equatable {
        case deposit(Int)
        case withdraw(Int)
    }
    
    /// Action에 대한 작업 단위 정의
    enum Mutation: Equatable {
        case increaseBalance(Int)
        case decreaseBalance(Int)
        case valueDidChanged(Bool)
    }
    
    // Output
    /// 현재 상태, view는 State를 구독하 UI를 업데이트 함
    struct State {
        var currentBalance: Int
        var statusDidChanged = false
    }
    
    // MARK: - Initializer
    
    init(data: BankData) {
        self.account = data.account
        self.initialState = State(currentBalance: data.account.balance)
    }
    
    // MARK: - Transform
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .deposit(let int):
            return Observable.concat([
                Observable.just(.valueDidChanged(true)),
                Observable.just(.increaseBalance(int)),
                Observable.just(.valueDidChanged(false))
            ])
        case .withdraw(let int):
            return Observable.concat([
                Observable.just(.valueDidChanged(true)),
                Observable.just(.decreaseBalance(int)),
                Observable.just(.valueDidChanged(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .increaseBalance(let int):
            newState.currentBalance += int
        case .decreaseBalance(let int):
            newState.currentBalance -= int
        case .valueDidChanged(let changed):
            newState.statusDidChanged = changed
        }
        return newState
    }
}
