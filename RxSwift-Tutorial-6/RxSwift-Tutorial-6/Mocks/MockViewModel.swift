//
//  MockViewMocel.swift
//  RxSwift-Tutorial-6
//
//  Created by Sam Sung on 2023/07/01.
//

import Foundation

final class MockViewModel: ViewModel {
    var account: BankAccount = BankAccount(balance: 10001230,
                                           history: [
                                            .deposit(20),
                                            .withdraw(30),
                                            .deposit(50)
                                           ])
}
