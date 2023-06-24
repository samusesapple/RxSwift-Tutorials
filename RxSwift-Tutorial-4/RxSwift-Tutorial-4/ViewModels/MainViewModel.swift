//
//  MainViewModel.swift
//  RxSwift-Tutorial-4
//
//  Created by Sam Sung on 2023/06/24.
//

import UIKit
import RxSwift
import RxCocoa

class MainViewModel {
    
    private var data: [Item]? = []
    
    private var searchText: BehaviorSubject<String?> = BehaviorSubject(value: "")
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Bind
    
    func bindInput(searchBar: UISearchBar, completion: @escaping () -> Void) {
        searchBar.rx.text.orEmpty
            .bind(to: searchText)
            .disposed(by: disposeBag)
        
        searchText
            .flatMap({ NetworkManager.shared.getSearchResult($0!) })
            .bind(onNext: { [weak self] item in
                self?.data = item
                completion()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Helpers
    
    var dataCount: Int {
        return data?.count ?? 0
    }
    
    func getTitle(index: Int) -> String? {
        return data?[index].title?.htmlToString
    }
    
    func getLink(index: Int) -> String? {
        return data?[index].link
    }

}
