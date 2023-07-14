//
//  ResultMapViewModel.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/07/14.
//

import Foundation
import RxSwift

class ResultMapViewModel: UserLocation {
    var userCoordinate: Coordinate
    
    let searchKeyword: String
    let placeDatas: [KeywordDocument]
    var targetPlace: KeywordDocument?
    
    init(userData: UserLocation, search: PlaceData) {
        self.userCoordinate = userData.userCoordinate
        self.searchKeyword = search.searchKeyword
        self.placeDatas = search.searchResults
        self.targetPlace = search.selectedPlace
        print(targetPlace?.placeName)
    }
}
