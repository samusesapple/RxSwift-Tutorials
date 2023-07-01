//
//  RxSwift_Tutorial_5Tests.swift
//  RxSwift-Tutorial-5Tests
//
//  Created by Sam Sung on 2023/07/01.
//

import XCTest
@testable import RxSwift_Tutorial_5
import RxSwift

final class RxSwift_Tutorial_5Tests: XCTestCase {

    // System Under Test
    private var sut: CalculatorViewModel!
    private var disposeBag = DisposeBag()
    
    override func setUp() {
        sut = CalculatorViewModel()
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        disposeBag = DisposeBag()
    }
    
    // MARK: - TestCode
    /* Test 1 :
              - total : 1000,
              - personCount: 4
     */
    func testResultWithtotal1000and4person() {
        // Given
        let total: Int = 1000
        let personCount: Int = 4
        // When
        let output = sut.transform(input: viewModelInput(total: total,
                                                         personCount: personCount))
        // Then
        output.resultObservable
            .bind { result in
                XCTAssertEqual(result.totalAmount, 1000)
                XCTAssertEqual(result.personCount, 4)
                XCTAssertEqual(result.amountPerPerseon, 250)
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Helpers
    
    func viewModelInput(total: Int, personCount: Int) -> CalculatorViewModel.Input {
        let totalSubject = BehaviorSubject(value: 1000)
        let personSubject = BehaviorSubject(value: 4)
        return CalculatorViewModel.Input(totalSubject: totalSubject,
                                              personSubject: personSubject)
    }

}
