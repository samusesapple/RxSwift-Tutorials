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
    
    private var startPage: Int = 1
    
    let disposeBag = DisposeBag()
    
    // MARK: - Bind
    
    struct Output {
        let title: String?
        let detail: String?
        let link: String?
    }
    
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
    
    func transform(index: Int = 0) -> Output {
        return Output(title: data?[index].title?.htmlToString,
                      detail: data?[index].description?.htmlToString,
                      link: data?[index].link)
    }
    
    // MARK: - Helpers

    
    var dataCount: Int {
        return data?.count ?? 0
    }

    func getLink(index: Int) -> String? {
        return data?[index].link
    }

    func getNextPageResults(completion: @escaping () -> Void) {
        guard let data = data,
                  data.count >= 20 else { return }
        
        startPage += 2
        searchText
            .flatMap({ [weak self] in
                NetworkManager.shared.getSearchResult($0!,
                                                      startPage: self!.startPage) })
            .bind { [weak self] items in
                items?.forEach({ self?.data?.append($0) })
                completion()
            }
            .disposed(by: disposeBag)
    }
}
