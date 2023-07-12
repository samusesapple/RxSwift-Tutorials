//
//  SearchResultViewReactor.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/07/12.
//

import Foundation
import ReactorKit

class SearchResultViewReactor: UserLocation, Reactor {
    var initialState: State
    
    var userCoordinate: Coordinate
    
    enum Action {
        case didTappedMapIcon
        case didTappedCell
        case didScrolledTableView
    }
    
    enum Mutation {
        case prepareMapView
        case getDetailDataForCell
        case getMorePlaceData
    }
    
    struct State {
        let searchResults: [KeywordDocument]
        let isLoading: Bool
        let showMapView: Bool
    }
    
    init(_ userData: UserLocation, searchResults: [KeywordDocument]) {
        self.userCoordinate = userData.userCoordinate
        self.initialState = State(searchResults: searchResults,
                                  isLoading: false,
                                  showMapView: false)
    }
}
