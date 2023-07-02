//
//  HistoryTableViewCell.swift
//  RxSwift-Tutorial-6
//
//  Created by Sam Sung on 2023/07/02.
//

import UIKit
import SnapKit
import Then

final class HistoryTableViewCell: UITableViewCell {

    private let typeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    }
    
    private let priceLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
    }

    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        setAutolayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    private func setAutolayout() {
        [typeLabel, priceLabel].forEach(contentView.addSubview)
        typeLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(6)
            make.left.equalTo(contentView.snp.left).offset(14)
        }
        priceLabel.snp.makeConstraints { make in
            make.centerY.equalTo(contentView.snp.centerY)
            make.right.equalTo(contentView.snp.right).offset(-18)
        }
    }
    
    func configureUIwithData(_ data: Transaction) {
        switch data {
        case .deposit(let price):
            typeLabel.text = "입금"
            typeLabel.textColor = .red.withAlphaComponent(0.7)
            priceLabel.text = "+ \(price)"
        case .withdraw(let price):
            typeLabel.text = "출금"
            typeLabel.textColor = .blue.withAlphaComponent(0.7)
            priceLabel.text = "- \(price)"
        }
    }
}
