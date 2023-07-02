//
//  TransactionViewModel.swift
//  RxSwift-Tutorial-6
//
//  Created by Sam Sung on 2023/07/02.
//

import Foundation
import RxSwift
import ReactorKit

final class TransactionViewModel: ViewModel, Reactor {
    
    let initialState: State
    
    var account: BankAccount
    
    private var disposeBag = DisposeBag()
    
    // Input
    /// view로부터 받는 action
    enum Action {
        case deposit(Int)
        case withdraw(Int)
    }
    
    // Action에 대한 작업
    enum Mutation {
        case increaseBalance(Int)
        case decreaseBalance(Int)
    }
    
    // Output
    /// 현재 상태, view는 State를 사용하여 UI를 업데이트 함
    struct State {
        let currentBalance: Int
    }
    
    // MARK: - Initializer
    
    init(viewModel: ViewModel) {
        self.account = viewModel.account
        self.initialState = State(currentBalance: viewModel.account.balance)
    }
    
    // MARK: - Transform
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .deposit(let amount):
            print("+\(amount)")
            return Observable.create { emitter in
                emitter.onNext(Mutation.increaseBalance(amount))
                return Disposables.create()
            }
        case .withdraw(let amount):
            print("-\(amount)")
            return Observable.create { emitter in
                emitter.onNext(Mutation.decreaseBalance(amount))
                return Disposables.create()
            }
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
