//
//  CalculatorViewModel.swift
//  RxSwift-Tutorial-5
//
//  Created by Sam Sung on 2023/06/25.
//

import Foundation
import RxSwift

class CalculatorViewModel {
    
    // MARK: - Input & Output
    
    var inputField: InputField = .totalAmount
    
    private var totalAmount: String = ""
    private var personCount: String = ""

    struct Input {
        let totalSubject: PublishSubject<Int>
        let personSubject: PublishSubject<Int>
    }
    
    struct Output {
        let totalAmountObservable: Observable<String>
        let personCountObservable: Observable<String>
        let amountPerPersonObservable: Observable<String>
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
        let totalAmountObservable = input.totalSubject.asObservable().map({ "\($0)" })
        let personCountObservable = input.personSubject.asObservable().map({ "\($0)" })
        let amountPerPerson = Observable.combineLatest(input.totalSubject,
                                                       input.personSubject)
            .map({ (Double($0) / Double($1)) * 100 })
            .map({ "\($0 / 100)"})
        
        return Output(totalAmountObservable: totalAmountObservable,
                      personCountObservable: personCountObservable,
                      amountPerPersonObservable: amountPerPerson)
    }
    
}

