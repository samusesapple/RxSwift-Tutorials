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
import ReactorKit

final class TransactionViewController: UIViewController, View {
    
    var disposeBag: RxSwift.DisposeBag
    
    private var reactor: TransactionReactor!
    
    // MARK: - Components
    
    let balanceView = BalanceLabelView()
    
    let amonutTextField = UITextField().then {
        $0.borderStyle = .roundedRect
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.gray.cgColor
        $0.layer.cornerRadius = 8
        $0.textAlignment = .center
        $0.keyboardType = .numberPad
        $0.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        $0.placeholder = "Type price"
    }
    
    let depositButton = TransactionButton(action: .deposit(0))
    
    let withdrawButton = TransactionButton(action: .withdraw(0))
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = balanceView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setAutolayout()
        
        bind(reactor: reactor)
    }
        
    init(data: BankData) {
        self.reactor = TransactionReactor(data: data)
        self.disposeBag = DisposeBag()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Bind

    func bind(reactor: TransactionReactor) {
        bindButtonAction(reactor)
        bindState(reactor)
    }
    
    // 버튼에 대한 액션 reactor에 전달
    private func bindButtonAction(_ reactor: TransactionReactor) {
        depositButton.rx.tap
            .filter({ [weak self] in
                self!.amonutTextField.text!.count > 0
            })
            .map({ [weak self] in
                self!.amonutTextField.text!
            })
            .map({ Reactor.Action.deposit(Int($0)!) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        withdrawButton.rx.tap
            .filter({ [weak self] in
                self!.amonutTextField.text!.count > 0
            })
            .map({ [weak self] in
                self!.amonutTextField.text!
            })
            .map({ Reactor.Action.withdraw(Int($0)!) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    // UI 업데이트
    private func bindState(_ reactor: TransactionReactor) {
        reactor.state
            .map({ $0.currentBalance })
            .map({ "\($0)"})
            .bind(to: balanceView.balanceLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map({ $0.statusDidChanged })
            .filter({ $0 != false })
            .map({ [weak self] _ in
                self!.balanceView.balanceLabel.text!
            })
            .subscribe(onNext: { value in
                NotificationCenterManager
                    .postCurrentBalanceChangeNotification(value: Int(value)!)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Helpers
    
    private func setAutolayout() {
        [amonutTextField, depositButton, withdrawButton]
            .forEach(view.addSubview)
 
        amonutTextField.snp.makeConstraints { make in
            make.top.equalTo(balanceView.balanceLabel.snp.bottom).offset(50)
            make.height.equalTo(50)
            make.left.equalTo(view.snp.left).offset(30)
            make.right.equalTo(view.snp.right).offset(-30)
        }
        
        depositButton.snp.makeConstraints { make in
            make.top.equalTo(amonutTextField.snp.bottom).offset(50)
            make.left.equalTo(view.snp.left).offset(40)
            make.width.equalTo(110)
        }
        
        withdrawButton.snp.makeConstraints { make in
            make.top.equalTo(amonutTextField.snp.bottom).offset(50)
            make.right.equalTo(view.snp.right).offset(-40)
            make.width.equalTo(110)
        }
    }
}
