//
//  MockData.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/07/11.
//

import Foundation

class MockLocationData: UserLocation {
    var userCoordinate: Coordinate
    
    init(coordinate: Coordinate) {
        self.userCoordinate = coordinate
    }
}
