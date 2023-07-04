//
//  TransactionViewModel.swift
//  RxSwift-Tutorial-6
//
//  Created by Sam Sung on 2023/07/02.
//

import Foundation
import ReactorKit

final class TransactionViewModel: BankData, Reactor {
    
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
    }
    
    // Output
    /// 현재 상태, view는 State를 구독하 UI를 업데이트 함
    struct State {
        let currentBalance: Int
    }
    
    // MARK: - Initializer
    
    init(data: BankData) {
        self.account = data.account
        self.initialState = State(currentBalance: data.account.balance)
    }
    
    // MARK: - Transform
    
    func mutate(action: Action) -> Observable<Mutation> {
        return Observable.create { emitter in
            switch action {
            case .deposit(let int):
                emitter.onNext(.increaseBalance(int))
            case .withdraw(let int):
                emitter.onNext(.decreaseBalance(int))
            }
            return Disposables.create()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case .increaseBalance(let int):
            return State(currentBalance: state.currentBalance + int)
        case .decreaseBalance(let int):
            return State(currentBalance: state.currentBalance - int)
        }
    }
}
