//
//  HistoryViewController.swift
//  RxSwift-Tutorial-6
//
//  Created by Sam Sung on 2023/07/01.
//

import UIKit
import RxSwift
import SnapKit
import Then

final class HistoryViewController: UIViewController {
    
    private var viewModel: HistoryViewModel
    
    // MARK: - Components
    
    private lazy var tableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.rowHeight = 60
        $0.dataSource = self
        $0.delegate = self
        $0.register(HistoryTableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        setAutolayout()
    }
    
    init(viewModel: ViewModel) {
        self.viewModel = HistoryViewModel(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Bind
    
    
    // MARK: - Helpers
    
    private func setAutolayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.height.equalTo(view.snp.height)
            make.width.equalTo(view.snp.width)
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as! HistoryTableViewCell
        cell.contentView.backgroundColor = .white
        cell.configureUIwithData(viewModel.history[indexPath.row])
        return cell
    }
    
    
}
