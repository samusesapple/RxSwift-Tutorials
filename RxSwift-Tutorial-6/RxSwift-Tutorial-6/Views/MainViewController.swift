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
    
    private var reactor: MainReactor!
    
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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(currentBalanceDidChanged),
                                               name: NotificationCenterManager.currentBalanceChangeNotification,
                                               object: nil)
    }
    
    // MARK: - Bind
    
    func bind(reactor: MainReactor) {
        self.reactor = reactor
        buttonActions(reactor)
        bindState(reactor)
    }
    
    private func buttonActions(_ reactor: MainReactor) {
        historyButton.rx.tap
            .map({ reactor.historyViewModel })
            .subscribe(onNext: { [weak self] in
                self?.navigationController?
                    .pushViewController(HistoryViewController(data: $0), animated: true)
            })
            .disposed(by: disposeBag)
        
        actionButton.rx.tap
            .map({ reactor.transactionViewModel })
            .map({ TransactionViewController(data: $0) })
            .subscribe(onNext: { [weak self] in
                self?.navigationController?
                    .pushViewController($0, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: MainReactor) {
        reactor.state
            .map({ "\($0.currentBalance)" })
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] balance in
                self?.balanceView.balanceLabel.text = balance
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    
    @objc private func currentBalanceDidChanged(_ notification: NSNotification) {
        if let dictionary = notification.object as? [String : Any],
           let value = dictionary["currentBalance"] as? Int {
            Observable.just(Reactor.Action.currentBalanceDidChanged(value))
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
        }
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

