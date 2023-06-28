//
//  CalculatorViewModel.swift
//  RxSwift-Tutorial-5
//
//  Created by Sam Sung on 2023/06/25.
//

import Foundation
import RxSwift

class CalculatorViewModel {
    
    var buttonSubject: PublishSubject<ButtonCommand> = PublishSubject()

    let disposeBag = DisposeBag()
    
    // MARK: - Input & Output
    
    struct Input {
        let totalSubject: BehaviorSubject<Double>
        let personSubject: BehaviorSubject<Double>
    }
  
    struct Output {
        let amountPerPersonObservable: Observable<String>
    }
    
    // MARK: - Methods
    
    func transform(input: Input) -> Output {
        let amountPerPerson = Observable.combineLatest(input.totalSubject,
                                                       input.personSubject)
            .map({ Formatter.currencyFormatter.string(from: ($0 / $1) as NSNumber)! })
        
        return Output(amountPerPersonObservable: amountPerPerson)
    }
    
    // return obervable about button action
    func buttonTapped(_ command: ButtonCommand) -> Observable<ButtonCommand> {
        return Observable.create { emitter in
            switch command {
            case .addNumber(let number):
                emitter.onNext(.addNumber(number))
            case .clear:
                emitter.onNext(.clear)
            case .next:
                print("Next button Tapped")
                emitter.onNext(.next)
            }
            return Disposables.create {
                print("disposed")
            }
        }
    }
}
