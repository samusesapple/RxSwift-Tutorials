//
//  ViewController.swift
//  RxSwift-Tutorial-6
//
//  Created by Sam Sung on 2023/07/01.
//

import UIKit
import Then
import SnapKit
import ReactorKit
import RxCocoa

final class MainViewController: UIViewController, View {
    
    private var reactor: BalanceViewModel!
    
    var disposeBag = DisposeBag()
    
    // MARK: - Components
    
    private let balanceView = BalanceLabelView()
    
    private let historyButton = UIButton(type: .system).then {
        $0.setTitle("Check History", for: .normal)
        $0.titleLabel?.tintColor = .white
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 19)
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .systemBlue
    }
    
    private let actionButton = UIButton(type: .system).then {
        $0.setTitle("Do Something!", for: .normal)
        $0.titleLabel?.tintColor = .white
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 19)
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .magenta
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = balanceView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setAutolayout()
    }
    
//    init(data: BankData) {
//        self.reactor = BalanceViewModel(data: data)
//        super.init(nibName: nil, bundle: nil)
////    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
    // MARK: - Bind
    
    func bind(reactor: BalanceViewModel) {
        buttonActions(reactor)
        bindState(reactor)
    }

    private func buttonActions(_ reactor: BalanceViewModel) {
        historyButton.rx.tap
            .map({ reactor.historyViewModel })
            .subscribe(onNext: { [weak self] in
                self?.navigationController?
                    .pushViewController(HistoryViewController(data: $0), animated: true)
            })
            .disposed(by: disposeBag)
        
        actionButton.rx.tap
            .map({ reactor.transactionViewModel })
            .map({ let transactionVC = TransactionViewController()
                transactionVC.bind(reactor: TransactionViewModel(data: $0))
                return transactionVC
            })
            .subscribe(onNext: { [weak self] in
                self?.navigationController?
                    .pushViewController($0, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: BalanceViewModel) {
        reactor.state
            .map({ "\($0.currentBalance)" })
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] balance in
                self?.balanceView.balanceLabel.text = balance
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Helpers
    
    private func setAutolayout() {
        [historyButton, actionButton]
            .forEach(view.addSubview)
        
        historyButton.snp.makeConstraints { make in
            make.top.equalTo(balanceView.balanceLabel.snp.bottom).offset(150)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(160)
            make.height.equalTo(45)
        }
        
        actionButton.snp.makeConstraints { make in
            make.top.equalTo(historyButton.snp.bottom).offset(40)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(160)
            make.height.equalTo(45)
        }
    }
}

