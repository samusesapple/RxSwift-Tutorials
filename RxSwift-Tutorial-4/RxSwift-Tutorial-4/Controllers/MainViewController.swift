//
//  ViewController.swift
//  RxSwift-Tutorial-4
//
//  Created by Sam Sung on 2023/06/22.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

class MainViewController: UIViewController {
    
    private var searchText: BehaviorSubject<String?> = BehaviorSubject(value: "")
    
    private var data: [Item]? = []
    
    private let disposeBag = DisposeBag()
    
// MARK: - Components
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var tableView = UITableView().then {
        $0.backgroundColor = .white
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        $0.dataSource = self
        $0.delegate = self
    }
    
// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.searchController = searchController
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.height.equalTo(view.frame.height)
            make.width.equalTo(view.frame.width)
        }
        
        bindInput()
    }

// MARK: - Bind
    
    private func bindInput() {
        searchController.searchBar.rx.text
            .orEmpty
            .bind(to: searchText)
            .disposed(by: disposeBag)
        
        searchText
            .filter({ $0 != nil })
            .flatMap({ NetworkManager.shared.getSearchResult($0!) })
            .bind(onNext: { [weak self] item in
                self?.data = item
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }

    
}

// MARK: - UITableViewDataSource

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = data?[indexPath.row].title?.htmlToString
        return cell
    }
    
    
}

