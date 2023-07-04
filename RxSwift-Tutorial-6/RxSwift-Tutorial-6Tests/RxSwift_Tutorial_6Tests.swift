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
        
    override func setUp() {
        sut = TransactionViewController()
    }
    
    override func tearDown() {
        sut = nil
    }
    
    // MARK: - Test Scenario
    
    func testAction_whenDidTapDepositButton_amount300_sendActions() {
        // Given
        let reactor = TransactionViewModel(data: MockData())
        reactor.isStubEnabled = true
        sut.reactor = reactor
        sut.amonutTextField.text = "300"
        
        // When
        sut.depositButton.sendActions(for: .touchUpInside)
        
        // Then
        XCTAssertEqual(reactor.stub.actions.last, .deposit(300))
    }
    
    func testAction_whenDidTapWithdrawButton_amount300_sendActions() {
        // Given
        let reactor = TransactionViewModel(data: MockData())
        reactor.isStubEnabled = true
        sut.reactor = reactor
        sut.amonutTextField.text = "300"
        
        // When
        sut.withdrawButton.sendActions(for: .touchUpInside)
        
        // Then
        XCTAssertEqual(reactor.stub.actions.last, .withdraw(300))
    }
}
