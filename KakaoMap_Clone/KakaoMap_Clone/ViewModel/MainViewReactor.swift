//
//  File.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/07/09.
//

import Foundation
import ReactorKit
import RxSwift

class MainViewReactor: Reactor {
    var initialState: State
    
    enum Action {
        case userDidMoved(Coordinate)
        case mapDidMoved(Coordinate)
        case menuButtonDidTapped
        case searchBarDidTapped
    }
    
    enum Mutation {
        case updateCurrentLocationCoordinate(Coordinate)
        case updateMapCenterCoordinate(Coordinate)
        case toggleMenuStatus(Bool)
        case willStartSearching(Bool)
    }
    
    struct State {
        var userLocationCoordinate: Coordinate
        var mapCenterCoordinate: Coordinate
        var menuIsOpend: Bool
        var shouldStartSearching: Bool = false
    }
    
    // MARK: - Initializer
    
    init(location: Coordinate) {
        self.initialState = State(userLocationCoordinate: location,
                                  mapCenterCoordinate: location,
                                  menuIsOpend: false,
                                  shouldStartSearching: false)
    }
    
    // MARK: - Bind
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .userDidMoved(let coordinate):
            return Observable.just(.updateCurrentLocationCoordinate(coordinate))
        case .mapDidMoved(let coordinate):
            return Observable.just(.updateMapCenterCoordinate(coordinate))
        case .menuButtonDidTapped:
            return Observable.just(.toggleMenuStatus(!initialState.menuIsOpend))
        case .searchBarDidTapped:
            return Observable.concat([
                Observable.just(.willStartSearching(true)),
                Observable.just(.willStartSearching(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .updateCurrentLocationCoordinate(let coordinate):
            newState.userLocationCoordinate = coordinate
        case .updateMapCenterCoordinate(let coordinate):
            newState.mapCenterCoordinate = coordinate
        case .toggleMenuStatus(let status):
            newState.menuIsOpend = status
        case .willStartSearching(let bool):
            newState.shouldStartSearching = bool
        }
        return newState
    }
}
