//
//  CalculatorViewModel.swift
//  RxSwift-Tutorial-5
//
//  Created by Sam Sung on 2023/06/25.
//

import Foundation
import RxSwift
import RxCocoa

class CalculatorViewModel {
    
    // MARK: - Input & Output
    
    var inputField: InputField = .totalAmount
    
    private var totalAmount: String = ""
    private var personCount: String = ""

    struct Input {
        let totalSubject: BehaviorSubject<Int>
        let personSubject: BehaviorSubject<Int>
    }
    
    struct Output {
        let resultObservable: Observable<Result>
    }
    
    // MARK: - Transform
    
    // Number Button - 눌린 버튼의 값을 stream에 보냄
    func getObservableForTappedNumber(_ buttonNumber: String) -> Observable<String> {
        return Observable.create({ [weak self] emitter in
            guard let self = self else { return Disposables.create() }
            
            switch self.inputField {
            case .totalAmount:
                self.totalAmount += buttonNumber
                emitter.onNext(self.totalAmount)
            case .personCount:
                self.personCount += buttonNumber
                emitter.onNext(self.personCount)
            }
            return Disposables.create()
        })
    }
    
    // Clear Button - clear 되면 초기값 세팅하도록 Observer return
    func shouldClearTextField() -> Observable<Int> {
        return Observable.create({ [weak self] emitter in
            guard let self = self else { return Disposables.create() }
            switch self.inputField {
            case .totalAmount:
                self.totalAmount = ""
                emitter.onNext(0)
            case .personCount:
                self.personCount = ""
                emitter.onNext(0)
            }
            return Disposables.create()
        })
    }
    
    // Next Button - 타겟 textField 변경
    func nextButtonToggled() -> Observable<InputField> {
        let target = inputField == .personCount ? InputField.totalAmount : InputField.personCount
        inputField = target
        print("target: \(inputField)")
        return Observable.create({ $0.onNext(target)
            return Disposables.create()
        })
    }
    
    func transform(input: Input) -> Output {
        let resultObservable = Observable.combineLatest(input.totalSubject,
                                                       input.personSubject)
            .map({ totalAmount, personCount in
                let amountPerPerson = Double(totalAmount) / Double(personCount)
                let result = Result(totalAmount: totalAmount,
                                    personCount: personCount,
                                    amountPerPerseon: amountPerPerson)
                return result
            })
        
        return Output(resultObservable: resultObservable)
    }
}

