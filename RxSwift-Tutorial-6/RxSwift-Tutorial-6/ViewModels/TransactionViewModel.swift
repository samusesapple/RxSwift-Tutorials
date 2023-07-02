//
//  TransactionViewModel.swift
//  RxSwift-Tutorial-6
//
//  Created by Sam Sung on 2023/07/02.
//

import Foundation
import RxSwift

final class TransactionViewModel: ViewModel {
    
    var account: BankAccount
    
    private var disposeBag = DisposeBag()
    
    // Input
    struct Input {
        let balanceSubject: BehaviorSubject<Int>
        let transactionSubject: PublishSubject<Transaction>
    }
    
    // Output
    struct Output {
        let balancePublisher: PublishSubject<Int>
    }
    
    // MARK: - Initializer
    
    init(viewModel: ViewModel) {
        self.account = viewModel.account
    }
    
    // MARK: - Transform
    
    func transform(input: Input) -> Output {
        let output = Output(balancePublisher: PublishSubject<Int>())
        
        Observable.zip(input.transactionSubject, input.balanceSubject)
            .map { action, total in
                switch action {
                case .deposit(let amount):
                    print("+\(amount)")
                    return total + amount
                    
                case .withdraw(let amount):
                    print("-\(amount)")
                    return total - amount
                }
            }
            .subscribe(output.balancePublisher)
            .disposed(by: disposeBag)
        
        return output
    }
}
