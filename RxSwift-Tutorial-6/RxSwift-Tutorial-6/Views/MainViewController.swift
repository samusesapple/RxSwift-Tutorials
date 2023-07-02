//
//  ViewController.swift
//  RxSwift-Tutorial-6
//
//  Created by Sam Sung on 2023/07/01.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

class MainViewController: UIViewController {
    
    var viewModel: BalanceViewModel
    
    private var disposeBag = DisposeBag()
    
    // MARK: - Components
    
    private let titleLabel = UILabel().then {
        $0.text = "Your Balance :"
        $0.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        $0.tintColor = .darkGray.withAlphaComponent(0.7)
        $0.textAlignment = .left
    }
    
    private let balanceLabel = UILabel().then {
        $0.text = "124,000"
        $0.font = UIFont.systemFont(ofSize: 36, weight: .semibold)
        $0.tintColor = .black
        $0.textAlignment = .center
    }
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setAutolayout()
        
        buttonActions()
        bindData()
    }
    
    init(viewModel: ViewModel) {
        self.viewModel = BalanceViewModel(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Bind
    
    private func buttonActions() {
        historyButton.rx.tap
            .map({ [weak self] in self!.viewModel.historyViewModel })
            .subscribe(onNext: { [weak self] in
                self?.present(HistoryViewController(viewModel: $0), animated: true)
            })
            .disposed(by: disposeBag)
        
        actionButton.rx.tap
            .map({ "action button" })
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindData() {
        viewModel.balanceObservable
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] balance in
            self?.balanceLabel.text = balance
        }
        .disposed(by: disposeBag)
    }
    
    // MARK: - Helpers
    
    private func setAutolayout() {
        [titleLabel, balanceLabel, historyButton, actionButton].forEach(view.addSubview)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(150)
            make.left.equalTo(view.snp.left).offset(30)
        }
        
        balanceLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(50)
            make.centerX.equalTo(view.snp.centerX)
        }
        
        historyButton.snp.makeConstraints { make in
            make.top.equalTo(balanceLabel.snp.bottom).offset(150)
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

