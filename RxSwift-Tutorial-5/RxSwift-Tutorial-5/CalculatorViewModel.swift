//
//  CalculatorViewModel.swift
//  RxSwift-Tutorial-5
//
//  Created by Sam Sung on 2023/06/25.
//

import Foundation
import RxSwift

/*
 1. button Tapped
 2. send button command to viewModel
 3. return buttonCommand Subjects (num(Just), clear(emit void), next(emit void))
 4. let VC subscribe 3's subjcets (Actions => 1. num : use it as Input of transform
 2. clear : let viewModel to clear target TF's text
 3. next : let viewModel to change target TF)
 */

class CalculatorViewModel {
    
    // MARK: - Input & Output
    
    var inputField: InputField = .totalAmount
    
    private var totalAmount: String = ""
    private var personCount: String = ""
    
    struct ButtonOutput {
        let numberSubject: Observable<String>
        let clearSubject: Observable<Int>
        let nextSubject: Observable<InputField>
    }
    
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
    
    // 눌린 버튼의 값을 stream에 보냄
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
    
    // 어느 target TF의 string 초기화, VC의 subject가 구독할 수 있도록 초기값 세팅해주는 Observer return
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
    
    // 타겟 textField 변경
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

