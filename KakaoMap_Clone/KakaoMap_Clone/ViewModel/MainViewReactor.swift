//
//  File.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/07/09.
//

import Foundation
import ReactorKit
import RxSwift

protocol UserLocation {
    var userCoordinate: Coordinate { get set }
}

class MainViewReactor: UserLocation, Reactor {
    var userCoordinate: Coordinate
    
    var initialState: State
    
    enum Action {
        case userDidMoved(Coordinate)
        case mapDidMoved(Coordinate)
        case menuButtonDidTapped
        case searchBarDidTapped
    }
    
    enum Mutation {
        case getCurrentLocationCoordinate(Coordinate)
        case getMapCenterAddress(String)
        case toggleMenuStatus(Bool)
        case willStartSearching(Bool)
    }
    
    struct State {
        var mapAddress: String
        var menuIsOpend: Bool
        var shouldStartSearching: Bool
    }
    
    // MARK: - Initializer
    
    init(location: Coordinate) {
        self.userCoordinate = location
        self.initialState = State(mapAddress: "",
                                  menuIsOpend: false,
                                  shouldStartSearching: false)
    }
    
    // MARK: - Bind
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .userDidMoved(let coordinate):
            return Observable.just(.getCurrentLocationCoordinate(coordinate))
            
        case .mapDidMoved(let coordinate):
            return HttpClient.shared.getLocationAddressObservable(coordinate: coordinate)
                .map({ $0.documents?.first?.addressName })
                .filter({ $0 != nil })
                .map({ Mutation.getMapCenterAddress($0!) })
            
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
        case .getCurrentLocationCoordinate(let coordinate):
            print("set CURRENT ADDRESS")
            userCoordinate = coordinate
        case .getMapCenterAddress(let address):
            print("MAP ADDRESS")
            newState.mapAddress = address
        case .toggleMenuStatus(let status):
            newState.menuIsOpend = status
        case .willStartSearching(let status):
            newState.shouldStartSearching = status
        }
        return newState
    }
    
    
}
