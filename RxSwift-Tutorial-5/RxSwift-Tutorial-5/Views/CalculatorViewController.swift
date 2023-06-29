//
//  ViewController.swift
//  RxSwift-Tutorial-5
//
//  Created by Sam Sung on 2023/06/25.
//

import UIKit
import RxSwift
import RxCocoa

class CalculatorViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = CalculatorViewModel()
    
    private var buttonSubject: PublishSubject<ButtonCommand> = PublishSubject()
    
    private var totalSubject: BehaviorSubject<Int> = BehaviorSubject(value: 0)
    private var personSubject: BehaviorSubject<Int> = BehaviorSubject(value: 1)
    
    private let disposableBag = DisposeBag()
    
    // MARK: - Components
    
    @IBOutlet weak var totalAmountTextField: UITextField!
    @IBOutlet weak var personCountTextField: UITextField!
    
    @IBOutlet weak var resultAmountLabel: UILabel!
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    @IBOutlet weak var button6: UIButton!
    @IBOutlet weak var button7: UIButton!
    @IBOutlet weak var button8: UIButton!
    @IBOutlet weak var button9: UIButton!
    @IBOutlet weak var button0: UIButton!
    
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        [button0, button1, button2, button3, button4, button5,
         button6, button7, button8, button9,
         clearButton, nextButton
        ].forEach(buttonInput)
        
        bindInput()
        bindOutput()
    }
    
    // MARK: - Bind
    
    /* input :
     1. button
       1-1) number button
       1-2) next button
       1-3) clear button
     
     2. textField text (only could change by button)
       2-1) total amount tf.text
       2-2) person count tf.text
     */
    
    private func buttonInput(_ button: UIButton) {
        button.rx.tap
            .map({ [weak self] event in
                guard let num = button.titleLabel?.text else {
                   return button == self?.clearButton ? ButtonCommand.clear : ButtonCommand.next
                }
                return ButtonCommand.addNumber(num)
            })
            .bind(to: buttonSubject)
            .disposed(by: disposableBag)
    }
    
    private func bindInput() {
        buttonSubject.subscribe(onNext: { [weak self] command in
            switch command {
            case .addNumber(let num):
                self?.viewModel.getObservableForTappedNumber(num)
                    .subscribe(onNext: { print("button Tapped: \($0)") })
                    .disposed(by: self!.disposableBag)
            case .clear:
                self?.viewModel.getTextFieldObservableToClear()
                    .subscribe(onNext: { print("need to clear : \($0)") })
                    .disposed(by: self!.disposableBag)
            case .next:
                self?.viewModel.nextButtonToggled()
                    .subscribe(onNext: { print("target TF : \($0)") })
                    .disposed(by: self!.disposableBag)
            }
        })
        .disposed(by: disposableBag)
    }
    
    /* output :
     1. number button : type text
     2. next button : resign tf firstResponder
     3. clear button : clear everything
     4. show amount per person
     */
    private func bindOutput() {
        let output = viewModel.transform(input: CalculatorViewModel.Input(buttonCommand: buttonSubject,
                                                                          totalSubject: totalSubject,
                                                                          personSubject: personSubject))
        output.totalAmountObservable
            .subscribe(onNext: { [weak self] in self?.totalAmountTextField.text = $0 })
            .disposed(by: disposableBag)
        
        output.personCountObservable
            .subscribe(onNext: { [weak self] in self?.personCountTextField.text = $0 })
            .disposed(by: disposableBag)
        
        output.amountPerPersonObservable
            .subscribe(onNext: { [weak self] in self?.resultAmountLabel.text = $0 })
            .disposed(by: disposableBag)
    }
    
}

