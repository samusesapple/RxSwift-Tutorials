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
    
    private var totalSubject: BehaviorSubject<Double> = BehaviorSubject(value: 0)
    private var personSubject: BehaviorSubject<Double> = BehaviorSubject(value: 1)

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
        bindInput()
        bindOutput()
    }

    func bindInput() {
        buttonInput()
        
        totalAmountTextField.rx.text
            .orEmpty
            .filter({ Double($0) != nil && Double($0)! > 0 })
            .map({ Double($0)! })
            .bind(to: totalSubject)
            .disposed(by: disposableBag)
        
        personCountTextField.rx.text
            .orEmpty
            .filter({ Double($0) != nil && Double($0)! > 0 })
            .map({ Double($0)! })
            .bind(to: personSubject)
            .disposed(by: disposableBag)
    }
    
    func buttonInput() {
        button0.rx.tap.map({ ButtonCommand.addNumber("0") })
            .bind(onNext: { [weak self] in self?.viewModel.buttonTapped($0) })
        .disposed(by: disposableBag)
        
        button1.rx.tap.map({ ButtonCommand.addNumber("1") })
            .bind(onNext: { [weak self] in self?.viewModel.buttonTapped($0) })
        .disposed(by: disposableBag)
        
        button2.rx.tap.map({ ButtonCommand.addNumber("2") })
            .bind(onNext: { [weak self] in self?.viewModel.buttonTapped($0) })
        .disposed(by: disposableBag)
        
        button3.rx.tap.map({ ButtonCommand.addNumber("3") })
            .bind(onNext: { [weak self] in self?.viewModel.buttonTapped($0) })
        .disposed(by: disposableBag)
        
        button4.rx.tap.map({ ButtonCommand.addNumber("4") })
            .bind(onNext: { [weak self] in self?.viewModel.buttonTapped($0) })
        .disposed(by: disposableBag)
        
    }
    
    func bindOutput() {
        viewModel.transform(input: CalculatorViewModel.Input(totalSubject: totalSubject,
                                                             personSubject: personSubject))
        .subscribe(onNext: { [weak self] in self?.resultAmountLabel.text = $0 })
        .disposed(by: disposableBag)
    }

}

