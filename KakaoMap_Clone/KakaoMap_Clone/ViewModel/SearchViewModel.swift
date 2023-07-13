//
//  SearchViewModel.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/07/13.
//

import Foundation
import RxCocoa
import RxSwift

class SearchViewModel: UserLocation {
    var userCoordinate: Coordinate
    
    var searchHistories: [SearchHistory] = []
    
    let searchOptions: [SearchOption] = {[
        SearchOption(icon: UIImage(systemName: "fork.knife")!, title: "맛집"),
        SearchOption(icon: UIImage(systemName: "cup.and.saucer.fill")!, title: "카페"),
        SearchOption(icon: UIImage(systemName: "24.square.fill")!, title: "편의점"),
        SearchOption(icon: UIImage(systemName: "cart.fill")!, title: "마트"),
        SearchOption(icon: UIImage(systemName: "pill.fill")!, title: "약국"),
        SearchOption(icon: UIImage(systemName: "train.side.rear.car")!, title: "지하철")
    ]}()
    
    // MARK: - Initializer
    
    init(_ userData: UserLocation) {
        self.userCoordinate = userData.userCoordinate
    }
    
    // MARK: - Transform
    
    func getSearchResultViewModel(keyword: String) -> Observable<SearchResultViewReactor> {
        return HttpClient.shared.searchKeywordObservable(with: keyword,
                                                  coordinate: userCoordinate,
                                                  page: 1)
        .filter({ $0.documents != nil })
        .map({ PlaceData(keyword: keyword,
                         data: $0.documents!) })
        .map({
            SearchResultViewReactor(self,
                                    search: $0)
        })
        
    }
    
    // MARK: - Helpers

    /// 글자수에 따라 collectionView Cell의 넓이 측정하여 Double 형태로 return
    func getCellWidth(with option: SearchOption) -> Double {
        if option.title.count <= 2 {
            return Double(option.title.count * 30)
        } else {
            return Double(option.title.count * 25)
        }
    }
}
