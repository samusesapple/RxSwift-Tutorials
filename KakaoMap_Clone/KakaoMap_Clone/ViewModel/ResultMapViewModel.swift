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
    let placeDatas: [ResultData]
    var targetPlace: ResultData?
    
    init(userData: UserLocation, search: PlaceDataType) {
        self.userCoordinate = userData.userCoordinate
        self.searchKeyword = search.searchKeyword
        self.placeDatas = search.searchResults
        self.targetPlace = search.selectedPlace
//        print(targetPlace?.placeName)
    }
}
