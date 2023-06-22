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
        loadProfileImage(data.avatar)
        avatar.image = nil       // 셀 재사용 때문에 nil로 초기화
        name.text = data.name
        job.text = data.job
        age.text = "\(data.age)"
    }
    
    private func loadProfileImage(_ data: String) {
        NetworkManager.shared.loadImage(from: data)
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: avatar.rx.image)
            .disposed(by: disposeBag)
    }
}


