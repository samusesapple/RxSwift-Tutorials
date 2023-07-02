//
//  BalanceLabelView.swift
//  RxSwift-Tutorial-6
//
//  Created by Sam Sung on 2023/07/02.
//

import UIKit
import SnapKit

final class BalanceLabelView: UIView {

    private let titleLabel = UILabel().then {
        $0.text = "Your Balance :"
        $0.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        $0.tintColor = .darkGray.withAlphaComponent(0.7)
        $0.textAlignment = .left
    }
    
    let balanceLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 36, weight: .semibold)
        $0.tintColor = .black
        $0.textAlignment = .center
    }

    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [titleLabel, balanceLabel].forEach(addSubview)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(150)
            make.left.equalTo(self.snp.left).offset(30)
        }
        
        balanceLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(50)
            make.centerX.equalTo(self.snp.centerX)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
