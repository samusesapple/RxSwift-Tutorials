//
//  ViewController.swift
//  RxSwift-Tutorial-3
//
//  Created by Sam Sung on 2023/06/21.
//

import UIKit
import RxCocoa
import RxSwift

class ViewController: UITableViewController {
    var data: [Member] = []
    var disposeBag = DisposeBag()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier,
            id == "DetailViewController",
            let detailVC = segue.destination as? DetailViewController,
            let data = sender as? Member else {
            return
        }
        detailVC.data = data
    }
    
    // MARK: - Helpers
    
    // 1. 서버로부터 멤버 데이터들 불러오기
    // 2. 데이터 다 받으면, 테이블뷰에 뿌리기
    // 3. 셀을 선택하면 셀에 해당되는 멤버의 세부정보를 보여주는 DetailVC로 넘어가기

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
