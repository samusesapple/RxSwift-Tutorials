//
//  DetailViewController.swift
//  RxSwift-Tutorial-3
//
//  Created by Sam Sung on 2023/06/21.
//

import RxCocoa
import RxSwift
import UIKit

class DetailViewController: UIViewController {
    var data: Member!

    @IBOutlet var avatar: UIImageView!
    @IBOutlet var id: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var job: UILabel!
    @IBOutlet var age: UILabel!

    var disposeBag = DisposeBag()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setData(data)
    }

    // MARK: - Bind Data
    
    // 선택된 셀에 해당되는 데이터 UI 띄우기
    func setData(_ data: Member) {
        getProfileImage(data.avatar)
        id.text = "\(data.id)"
        name.text = data.name
        job.text = data.job
        age.text = "\(data.age)"
    }

    // MARK: - Helpers
    
    private func getProfileImage(_ data: String) {
        NetworkManager.shared.loadImage(from: data)
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: avatar.rx.image)
            .disposed(by: disposeBag)
    }
    
    private func makeBig(_ url: String) -> Observable<String> {
        return Observable.just(url)
            .map { $0.replacingOccurrences(of: "size=50x50&", with: "") }
    }

}
