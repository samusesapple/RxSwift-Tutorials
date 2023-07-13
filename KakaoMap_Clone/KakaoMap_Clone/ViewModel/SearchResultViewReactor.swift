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
        case didStartedSearching
        case didScrolledTableView
        case didTappedCell
        case didTappedMapIcon
    }
    
    enum Mutation {
        case returnToPreviousView(Bool)
        case prepareMapView
        case getDetailDataForCell
        case getMorePlaceData
    }
    
    struct State {
        let searchKeyword: String
        var searchResults: [KeywordDocument]
//        var startSearching: Bool
        var isLoading: Bool
        var showMapView: Bool
    }
    
    init(_ userData: UserLocation, search: PlaceData) {
        self.userCoordinate = userData.userCoordinate
        self.initialState = State(searchKeyword: search.keyword,
                                  searchResults: search.data,
//                                  startSearching: false,
                                  isLoading: false,
                                  showMapView: false)
    }
    
    // MARK: - Transform
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .didStartedSearching:
            return Observable.just(.returnToPreviousView(true))
        case .didScrolledTableView:
            return Observable.just(.getMorePlaceData)
        case .didTappedCell:
            return Observable.just(.getDetailDataForCell)
        case .didTappedMapIcon:
            return Observable.just(.prepareMapView)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
    // [ERROR] - 검색 탭 한번 누르면 바로 popVC 안되는 버그 개선 필요
        case .returnToPreviousView(let _):
            print("이전 검색 화면으로 돌아가기")
//            newState.startSearching = status
            newState.searchResults = []
            return newState
        case .getMorePlaceData:
            print("네트워킹해서 장소 정보 더 받아와야함")
            return newState
        case .getDetailDataForCell:
            print("선택된 셀에 대한 정보 띄우기")
            return newState
        case .prepareMapView:
            print("지도로 장소 확인하도록 mapVC 띄우기")
            return newState
        }
    }
}
