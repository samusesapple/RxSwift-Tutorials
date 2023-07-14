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
    var targetPlace: KeywordDocument?
    
    init(userData: UserLocation, selected: KeywordDocument) {
        self.userCoordinate = userData.userCoordinate
        self.targetPlace = selected
    }
}
