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
        
    private let viewModel = MainViewModel()
        
// MARK: - Components
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var tableView = UITableView().then {
        $0.backgroundColor = .white
        $0.rowHeight = 115
        $0.register(UINib(nibName: "MainTableViewCell"
                          , bundle: nil),
                    forCellReuseIdentifier: "mainCell")
        $0.dataSource = self
        $0.delegate = self
    }
    
// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.searchController = searchController
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.height.equalTo(view.frame.height)
            $0.width.equalTo(view.frame.width)
        }
        
        bindInput()
    }
    

// MARK: - Bind
    
    private func bindInput() {
        viewModel.bindInput(searchBar: searchController.searchBar) { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell") as! MainTableViewCell

        let output = viewModel.transform(index: indexPath.row)
        cell.titleLabel.text = output.title
        cell.detailLabel.text = output.detail
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let link = viewModel.getLink(index: indexPath.row) else { return }
        let detailVC = DetailViewController(url: link)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.height {
            viewModel.getNextPageResults { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
}

