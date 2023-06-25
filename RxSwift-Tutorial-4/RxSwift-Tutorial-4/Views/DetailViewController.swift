//
//  DetailViewController.swift
//  RxSwift-Tutorial-4
//
//  Created by Sam Sung on 2023/06/24.
//

import UIKit
import WebKit
import SnapKit

class DetailViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    private let webView = WKWebView()
    
    private var url: URL
    
// MARK: - Initializer
    
    init(url: String) {
        self.url = URL(string: url)!
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

// MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    
        view.addSubview(webView)
        webView.snp.makeConstraints {
            $0.bottom.equalTo(view.snp.bottom)
            $0.height.equalTo(view.frame.height - 100)
            $0.width.equalTo(view.frame.width)
        }
            
        configureWebView()
    }

// MARK: - Helers
    
    func configureWebView() {
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        webView.navigationDelegate = self
        
        webView.load(URLRequest(url: url))
    }
}
