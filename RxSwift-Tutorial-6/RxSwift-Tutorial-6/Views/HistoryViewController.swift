//
//  HistoryViewController.swift
//  RxSwift-Tutorial-6
//
//  Created by Sam Sung on 2023/07/01.
//

import UIKit

class HistoryViewController: UIViewController {
    
    private var viewModel: HistoryViewModel
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        view.backgroundColor = .blue
    }
    
    init(viewModel: HistoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
