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
    
    init(viewModel: ViewModel) {
        self.account = viewModel.account
    }
}
