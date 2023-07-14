//
//  SearchViewModel.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/07/13.
//

import Foundation
import ReactorKit

class SearchViewModel: UserLocation, Reactor {
    
    var initialState: State
    
    enum Action {
        case startedSearching(String)
    }
    
    enum Mutation {
        case setKeyword(String)
        case getSearchResultDatas([KeywordDocument])
    }
    
    struct State: PlaceDataType {
        var searchKeyword: String
        var searchResults: [ResultData]
        var selectedPlace: ResultData?
    }
    
    var userCoordinate: Coordinate
    
    var searchHistories: [SearchHistory] = []
    var disposeBag = DisposeBag()
    
    var resultDataPublisher = PublishSubject<[ResultData]>()
    

    
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
        self.initialState = State(searchKeyword: "",
                                  searchResults: [])
    }
    
    // MARK: - Transform
 
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .startedSearching(let keyword):
            let documentsObservable = HttpClient.shared.searchKeywordObservable(with: keyword,
                                                             coordinate: userCoordinate,
                                                             page: 1)
            .filter({ $0.documents != nil })
            .map({ Mutation.getSearchResultDatas($0.documents!) })
            return Observable.merge([
                documentsObservable,
                Observable.just(.setKeyword(keyword))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .getSearchResultDatas(let documents):
            let dataObservable = documents.compactMap(getSearchResultDetail)
            let final = Observable.combineLatest(dataObservable)
            
            final.bind(to: resultDataPublisher)
                .disposed(by: disposeBag)
            
        case .setKeyword(let keyword):
            newState.searchKeyword = keyword
        }
        return newState
    }
    
    func getSearchResultDetail(searchResult: KeywordDocument) -> Observable<ResultData> {
        return HttpClient.shared.getDetailDataObservable(placeCode: searchResult.id!)
            .map({
                ResultData(placeInfo: searchResult,
                           placeDetail: $0)
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
