//
//  TransactionViewController.swift
//  RxSwift-Tutorial-6
//
//  Created by Sam Sung on 2023/07/02.
//

import UIKit
import SnapKit
import Then
import RxCocoa
import RxSwift

final class TransactionViewController: UIViewController {

    private var viewModel: TransactionViewModel
    
    private var balanceSubject: BehaviorSubject<Int>
    
    var disposableBag = DisposeBag()
    
    // MARK: - Components
    
    private let balanceView = BalanceLabelView()
    
    private let priceTextField = UITextField().then {
        $0.borderStyle = .roundedRect
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.gray.cgColor
        $0.layer.cornerRadius = 8
        $0.textAlignment = .center
        $0.keyboardType = .numberPad
        $0.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        $0.placeholder = "Type price"
    }
    
    private let depositButton = TransactionButton(action: .deposit(0))
    
    private let withdrawButton = TransactionButton(action: .withdraw(0))
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = balanceView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setAutolayout()
        
        buttonAction()
        bindData()
    }
        
    init(viewModel: ViewModel) {
        self.viewModel = TransactionViewModel(viewModel: viewModel)
        self.balanceSubject = BehaviorSubject(value: viewModel.account.balance)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Bind
    
    private func buttonAction() {
        depositButton.rx.tap
            .map({ "deposit button Tapped" })
            .bind(onNext: { print($0) })
            .disposed(by: disposableBag)
        
        withdrawButton.rx.tap
            .map({ "withdraw button Tapped" })
            .bind(onNext: { print($0) })
            .disposed(by: disposableBag)
    }
    
    private func bindData() {
        balanceSubject
            .map({ "\($0)"})
            .bind(to: balanceView.balanceLabel.rx.text)
            .disposed(by: disposableBag)
    }
    
    // MARK: - Helpers
    
    private func setAutolayout() {
        [priceTextField, depositButton, withdrawButton]
            .forEach(view.addSubview)
 
        priceTextField.snp.makeConstraints { make in
            make.top.equalTo(balanceView.balanceLabel.snp.bottom).offset(50)
            make.height.equalTo(50)
            make.left.equalTo(view.snp.left).offset(30)
            make.right.equalTo(view.snp.right).offset(-30)
        }
        
        depositButton.snp.makeConstraints { make in
            make.top.equalTo(priceTextField.snp.bottom).offset(50)
            make.left.equalTo(view.snp.left).offset(40)
            make.width.equalTo(110)
        }
        
        withdrawButton.snp.makeConstraints { make in
            make.top.equalTo(priceTextField.snp.bottom).offset(50)
            make.right.equalTo(view.snp.right).offset(-40)
            make.width.equalTo(110)
        }
    }
}
