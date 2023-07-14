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
        case didScrolledTableView
        case didTappedCell(Int)
        case didTappedMapIcon
    }
    
    enum Mutation {
        case prepareMapView
        case getDetailDataForCell(Int)
        case getMorePlaceData
    }
    
    struct State: PlaceData {
        var searchKeyword: String
        var searchResults: [KeywordDocument]
        var selectedPlace: KeywordDocument?
    }
    
    init(_ userData: UserLocation, search: PlaceData) {
        self.userCoordinate = userData.userCoordinate
        self.initialState = State(searchKeyword: search.searchKeyword,
                                  searchResults: search.searchResults,
                                  selectedPlace: nil)
    }
    
    // MARK: - Transform
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .didScrolledTableView:
            return Observable.just(.getMorePlaceData)
        case .didTappedCell(let index):
            return Observable.just(.getDetailDataForCell(index))
        case .didTappedMapIcon:
            return Observable.just(.prepareMapView)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
    // [ERROR] - 검색 탭 한번 누르면 바로 popVC 안되는 버그 개선 필요
        case .getMorePlaceData:
            print("네트워킹해서 장소 정보 더 받아와야함")
            return newState
        case .getDetailDataForCell(let index):
            newState.selectedPlace = newState.searchResults[index]
            return newState
        case .prepareMapView:
            print("지도로 장소 확인하도록 mapVC 띄우기")
            return newState
        }
    }
}
