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
    var initialState: State
    
    var userCoordinate: Coordinate
    
    let searchOptions: [SearchOption] = {[
        SearchOption(icon: UIImage(systemName: "fork.knife")!, title: "맛집"),
        SearchOption(icon: UIImage(systemName: "cup.and.saucer.fill")!, title: "카페"),
        SearchOption(icon: UIImage(systemName: "24.square.fill")!, title: "편의점"),
        SearchOption(icon: UIImage(systemName: "cart.fill")!, title: "마트"),
        SearchOption(icon: UIImage(systemName: "pill.fill")!, title: "약국"),
        SearchOption(icon: UIImage(systemName: "train.side.rear.car")!, title: "지하철")
    ]}()
    
    enum Action {
        case viewDidLoad
        case didTappedSearchButton
    }
    
    enum Mutation {
        case shouldUpdateSearchHistory(Bool)
        case presentSearchResultView(Coordinate)
    }
    
    struct State {
        var updateSearchHistory: Bool
        var showSearchResult: Coordinate
    }
    
    // MARK: - Initializer
    
    init(_ data: UserLocation) {
        self.initialState = State(updateSearchHistory: false,
                                  showSearchResult: data.userCoordinate)
        self.userCoordinate = data.userCoordinate
    }
    
    // MARK: - Transform
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return Observable.concat([
                Observable.just(.shouldUpdateSearchHistory(true)),
                Observable.just(.shouldUpdateSearchHistory(false))
            ])
        case .didTappedSearchButton:
            return Observable.just(.presentSearchResultView(userCoordinate))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .shouldUpdateSearchHistory(let update):
            newState.updateSearchHistory = update
            
        case .presentSearchResultView(let userCoord):
            newState.showSearchResult = userCoord
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
