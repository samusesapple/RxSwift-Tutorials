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
    
    enum Action {
        case viewDidLoad
        case didTappedSearchButton
    }
    
    struct State {
        var searchHistories: [SearchHistory]
        var shoudPresentSearchResultView: Bool
    }
    
    init(_ data: UserLocation) {
        self.initialState = State(searchHistories: [],
                                  shoudPresentSearchResultView: false)
        self.userCoordinate = data.userCoordinate
    }
    
}
