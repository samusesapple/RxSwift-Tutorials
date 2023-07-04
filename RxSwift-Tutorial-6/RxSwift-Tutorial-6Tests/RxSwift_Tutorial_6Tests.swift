//
//  RxSwift_Tutorial_6Tests.swift
//  RxSwift-Tutorial-6Tests
//
//  Created by Sam Sung on 2023/07/04.
//

import XCTest
@testable import RxSwift_Tutorial_6
import ReactorKit

final class RxSwift_Tutorial_6Tests: XCTestCase {

    private var sut: TransactionViewController!
    private var mockData = MockData(account: BankAccount(balance: 0,
                                                         history: []))
    
    override func setUp() {
        sut = TransactionViewController(data: mockData)
    }
    
    override func tearDown() {
        sut = nil
    }
    
    // MARK: - View -> Reactor Action Test
    
    private func testAction_whenDidTapDepositButton_amount300_sendActions() {
        // Given
        let reactor = TransactionReactor(data: mockData)
        reactor.isStubEnabled = true
        sut.reactor = reactor
        sut.amonutTextField.text = "300"
        
        // When
        sut.depositButton.sendActions(for: .touchUpInside)
        
        // Then
        XCTAssertEqual(reactor.stub.actions.last, .deposit(300))
    }
    
    private func testAction_whenDidTapWithdrawButton_amount300_sendActions() {
        // Given
        let reactor = TransactionReactor(data: mockData)
        reactor.isStubEnabled = true
        sut.reactor = reactor
        sut.amonutTextField.text = "300"
        
        // When
        sut.withdrawButton.sendActions(for: .touchUpInside)
        
        // Then
        XCTAssertEqual(reactor.stub.actions.last, .withdraw(300))
    }
    
    // MARK: - Reactor (State status about Mutation) Test
    
    private func testStateStatus_whenDeposit300_thenBalanceStateIs300() {
        // Given
        let reactor = TransactionReactor(data: mockData)
        
        // When
        reactor.action.onNext(.deposit(300))
        
        // Then
        XCTAssertEqual(reactor.currentState.currentBalance, 300)
    }
    
    private func testStateStatus_whenWIthdraw300_thenBalanceStateIsMinus300() {
        // Given
        let reactor = TransactionReactor(data: mockData)
        
        // When
        reactor.action.onNext(.withdraw(300))
        
        // Then
        XCTAssertEqual(reactor.currentState.currentBalance, -300)
    }
    
    // MARK: - Reactor -> View (View observing State Value) Test
    
    private func testState_whenStateValueIs300_thenTextFieldTextIs300() {
        // Given
        let reactor = TransactionReactor(data: mockData)
        reactor.isStubEnabled = true
        
        sut.reactor = reactor
        
        // When
        reactor.stub.state.value = .init(currentBalance: 300)
        
        // Then
        let testBalance = sut.balanceView.balanceLabel.text
        XCTAssertEqual(testBalance, "300")
    }
}
