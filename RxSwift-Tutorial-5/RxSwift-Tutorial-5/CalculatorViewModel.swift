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
    
    private var inputField: InputField = .totalAmount
    
    struct ButtonOutput {
        let numberSubject: Observable<String>
        let clearSubject: Observable<Void>
        let nextSubject: Observable<Void>
    }
    
    struct Input {
        let buttonCommand: PublishSubject<ButtonCommand>
        let totalSubject: BehaviorSubject<Int>
        let personSubject: BehaviorSubject<Int>
    }
  
    struct Output {
        let totalAmountObservable: Observable<String>
        let personCountObservable: Observable<String>
        let amountPerPersonObservable: Observable<String>
    }
    
    // MARK: - Methods
    // 눌린 버튼의 값을 stream에 보냄
    func getObservableForTappedNumber(_ buttonNumber: String) -> Observable<String> {
        return Observable.just(buttonNumber)
    }
    
    // 어느 tf가 clear 되어야하는지를 stream에 보냄
    func getTextFieldObservableToClear() -> Observable<InputField> {
        return Observable.just(inputField)
    }
    
    // 타겟 textField 변경
    func nextButtonToggled() -> Observable<InputField> {
        let target = inputField == .personCount ? InputField.totalAmount : InputField.personCount
        inputField = target
        
        return Observable.just(target)
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
