//
//  CalculatorViewModel.swift
//  RxSwift-Tutorial-5
//
//  Created by Sam Sung on 2023/06/25.
//

import Foundation
import RxSwift

enum ButtonCommand {
    case clear
    case next
    case addNumber(Character)
}

class CalculatorViewModel {
    let disposeBag = DisposeBag()
    
    struct Input {
        let totalSubject: BehaviorSubject<Double>
        let personSubject: BehaviorSubject<Double>
    }
    
    func transform(input: Input) -> Observable<String> {
        return Observable
            .combineLatest(input.totalSubject,
                           input.personSubject)
            .map { String(((100*($0 / $1)).rounded()) / 100) }
    }
    
    func buttonTapped(_ command: ButtonCommand) {
        switch command {
        case .addNumber(let number):
            print(number)
        case .clear:
            print("Clear button Tapped")
        case .next:
            print("Next button Tapped")
        }
    }
    
}
