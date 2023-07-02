//
//  TransactionButton.swift
//  RxSwift-Tutorial-6
//
//  Created by Sam Sung on 2023/07/02.
//

import UIKit

final class TransactionButton: UIButton {
    
    init(action: Transaction) {
        super.init(frame: .zero)
        
        switch action {
        case .deposit(_):
            setTitle("Deposit \n+", for: .normal)
            backgroundColor = .red.withAlphaComponent(0.7)
            
        case .withdraw(_):
            setTitle("Withdraw \n-", for: .normal)
            backgroundColor = .blue.withAlphaComponent(0.7)
        }
        
        titleLabel?.numberOfLines = 2
        titleLabel?.textAlignment = .center
        titleLabel?.tintColor = .white
        titleLabel?.font = UIFont.systemFont(ofSize: 19)
        layer.cornerRadius = 8
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
