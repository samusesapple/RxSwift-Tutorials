//
//  SearchViewReactor.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/07/11.
//

import Foundation
import ReactorKit
import RxSwift

class SearchViewReactor: UserLocation, Reactor {
    
    let searchOptions: [SearchOption] = {[
        SearchOption(icon: UIImage(systemName: "fork.knife")!, title: "맛집"),
        SearchOption(icon: UIImage(systemName: "cup.and.saucer.fill")!, title: "카페"),
        SearchOption(icon: UIImage(systemName: "24.square.fill")!, title: "편의점"),
        SearchOption(icon: UIImage(systemName: "cart.fill")!, title: "마트"),
        SearchOption(icon: UIImage(systemName: "pill.fill")!, title: "약국"),
        SearchOption(icon: UIImage(systemName: "train.side.rear.car")!, title: "지하철")
    ]}()
    
    var initialState: State
    
    var userCoordinate: Coordinate
    var searchHistories: [SearchHistory] = []

    enum Action {
        case didTappedSearchButton(String)
    }
    
    enum Mutation {
        case reloadData(Bool)
        case shouldUpdateSearchHistory(SearchHistory)
        case getSearchResult([KeywordDocument])
    }
    
    struct State {
        var updateSearchHistory: Bool
        var showSearchResult: [KeywordDocument]
    }
    
    // MARK: - Initializer
    
    init(_ data: UserLocation) {
        self.initialState = State(updateSearchHistory: false,
                                  showSearchResult: [])
        self.userCoordinate = data.userCoordinate
    }
    
    // MARK: - Transform
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .didTappedSearchButton(let keyword):
            print("didTappedSearchButton")
            return HttpClient.shared.searchKeywordObservable(with: keyword,
                                                             coordinate: userCoordinate,
                                                             page: 1)
            .map({ $0.documents })
            .filter({ $0 != nil })
            .map({ Mutation.getSearchResult($0!) })
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .reloadData(_):
            newState.updateSearchHistory = true
        case .shouldUpdateSearchHistory(let newHistory):
            searchHistories.append(newHistory)
            
        case .getSearchResult(let searchResults):
            print("getSearchResult")
            newState.showSearchResult = searchResults
        }
        return newState
            
    }
    
    // MARK: - Helpers

    /// 글자수에 따라 collectionView Cell의 넓이 측정하여 Double 형태로 return
    func getCellWidth(with option: SearchOption) -> Double {
        if option.title.count <= 2 {
            return Double(option.title.count * 30)
        } else {
            return Double(option.title.count * 25)
        }
    }
}
