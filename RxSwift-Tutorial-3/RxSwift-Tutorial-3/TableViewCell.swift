//
//  TableViewCell.swift
//  RxSwift-Tutorial-3
//
//  Created by Sam Sung on 2023/06/21.
//

import UIKit
import RxSwift
import RxCocoa

// MARK: - TableView Cell

class MemberItemCell: UITableViewCell {
    @IBOutlet var avatar: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var job: UILabel!
    @IBOutlet var age: UILabel!
    
    var disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    // MARK: - Helpers
    
    // 데이터로 각 셀에 UI 띄우기
    func setData(_ data: Member) {

    }

}


