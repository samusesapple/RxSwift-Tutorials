//
//  ViewController.swift
//  RxSwift-Tutorial-3
//
//  Created by Sam Sung on 2023/06/21.
//

import UIKit
import RxCocoa
import RxSwift

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

class ViewController: UITableViewController {
    var data: [Member] = []
    var disposeBag = DisposeBag()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

//        loadMembers()
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] members in
//                self?.data = members
//                self?.tableView.reloadData()
//            })
//            .disposed(by: disposeBag)
    }

    // MARK: - Helpers
    
    // 1. 서버로부터 멤버 데이터들 불러오기
    // 2. 데이터 다 받으면, 테이블뷰에 뿌리기
    // 3. 셀을 선택하면 셀에 해당되는 멤버의 세부정보를 보여주는 DetailVC로 넘어가기


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier,
            id == "DetailViewController",
            let detailVC = segue.destination as? DetailViewController,
            let data = sender as? Member else {
            return
        }
        detailVC.data = data
    }
}

// MARK: - TableView Delegate & Datasource

extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberItemCell") as! MemberItemCell
        let item = data[indexPath.row]

        cell.setData(item)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = data[indexPath.row]
        performSegue(withIdentifier: "DetailViewController", sender: item)
    }
}

// MARK: TableView Cell

class MemberItemCell: UITableViewCell {
    @IBOutlet var avatar: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var job: UILabel!
    @IBOutlet var age: UILabel!

    func setData(_ data: Member) {
        loadImage(from: data.avatar)
            .observeOn(MainScheduler.instance)
            .bind(to: avatar.rx.image)
            .disposed(by: disposeBag)
        avatar.image = nil
        name.text = data.name
        job.text = data.job
        age.text = "(\(data.age))"
    }

    var disposeBag = DisposeBag()

    private func loadImage(from url: String) -> Observable<UIImage?> {
        return Observable.create { emitter in
            let task = URLSession.shared.dataTask(with: URL(string: url)!) { data, _, error in
                if let error = error {
                    emitter.onError(error)
                    return
                }
                guard let data = data,
                    let image = UIImage(data: data) else {
                    emitter.onNext(nil)
                    emitter.onCompleted()
                    return
                }

                emitter.onNext(image)
                emitter.onCompleted()
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}


