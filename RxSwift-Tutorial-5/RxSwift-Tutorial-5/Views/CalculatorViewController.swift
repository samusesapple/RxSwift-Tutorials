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
    
    private var targetInputFieldSubject: BehaviorSubject<InputField> = BehaviorSubject(value: .totalAmount)
    private var totalSubject: PublishSubject<Int> = PublishSubject()
    private var personSubject: PublishSubject<Int> = PublishSubject()
    
    private var disposableBag = DisposeBag()
    
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
        configureFocusedTextFieldColor()
    }
    
    // MARK: - Bind
    
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
            guard let self = self else { return }
            
            switch command {
            case .addNumber(let num):
                let numObserver = viewModel.getObservableForTappedNumber(num)
                    .map({ Int($0)! })
                
                switch viewModel.inputField {
                case .totalAmount:
                    numObserver
                        .subscribe(self.totalSubject)
                        .disposed(by: self.disposableBag)
                case .personCount:
                    numObserver
                        .subscribe(self.personSubject)
                        .disposed(by: self.disposableBag)
                }
                
            case .clear:
                let clearObserver = viewModel.shouldClearTextField()
        
                switch viewModel.inputField {
                case .totalAmount:
                    clearObserver
                        .subscribe(totalSubject)
                        .disposed(by: self.disposableBag)
                case .personCount:
                    clearObserver
                        .subscribe(personSubject)
                        .disposed(by: self.disposableBag)
                }
                
            case .next:
                self.viewModel.nextButtonToggled()
                    .subscribe(targetInputFieldSubject)
                    .disposed(by: self.disposableBag)
            }
        })
        .disposed(by: disposableBag)
    }
    
    private func bindOutput() {
        let output = viewModel.transform(input: CalculatorViewModel.Input(totalSubject: totalSubject,
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
    
    private func configureFocusedTextFieldColor() {
        targetInputFieldSubject.subscribe(onNext: { [weak self] field in
            switch field {
            case .totalAmount:
                self?.totalAmountTextField.textColor = .black
                self?.personCountTextField.textColor = .gray
            case .personCount:
                self?.totalAmountTextField.textColor = .gray
                self?.personCountTextField.textColor = .black
            }
        })
        .disposed(by: disposableBag)
    }
}

