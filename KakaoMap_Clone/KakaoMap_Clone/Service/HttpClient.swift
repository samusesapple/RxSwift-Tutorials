//
//  NetworkManager.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/23.
//

import Alamofire
import Foundation
import RxSwift

final class HttpClient {
    
    static let shared = HttpClient()
    
    private let host = "https://dapi.kakao.com/v2/local/"
    
    private let headers : HTTPHeaders = [
        "Authorization": "KakaoAK 7191f8213395eb70804dc67e8f329611"
    ]
    
    private init() { }
    
    // MARK: - Functions
    
    private func currentAddressParameters(coordinate: Coordinate) -> [String: Any] {
        [
            "x": coordinate.stringLongtitude,
            "y": coordinate.stringLatitude
        ]
    }
    
    private func keywordParameters(query: String, coordinate: Coordinate, page: Int, isAccurancy: Bool) -> [String: Any] {
        [
            "query": query,
            "x": coordinate.stringLongtitude,
            "y": coordinate.stringLatitude,
            "page": page,
            "sort": isAccurancy ? "accuracy": "distance"
        ]
    }
    
    private func directionParameters(startPoint: Coordinate, destination: Coordinate) -> [String: Any] {
        [
            "origin": startPoint.totalCoordinate,
            "destination": destination.totalCoordinate
        ]
    }
    
    /// 지정된 위치에 해당하는 카카오맵 데이터 크롤링하기
    func getDetailDataForTargetPlace(placeCode: String, completion: @escaping (TargetPlaceDetail) -> Void) {
        let url = "https://place.map.kakao.com/main/v/" + placeCode
        AF.request(url,
                   method: .get,
                   encoding: URLEncoding.default)
        .responseDecodable(of: TargetPlaceDetail.self) { response in
            let result = response.result
            switch result {
            case .success(let results):
                print("해당 위치 정보 가져오기 성공")
                completion(results)
                return
            case .failure(let error):
                print("해당 위치 정보 가져오기 실패")
                print(error)
            }
        }
    }
    
    /// 주소로 검색하기 (건물명, 도로명, 지번, 우편번호 및 좌표)
    func getLocationAddress(coordinate: Coordinate, completion: @escaping (CurrentAddressResult) -> Void) {
        let url = host + "geo/coord2regioncode.json"
        AF.request(url,
                   method: .get,
                   parameters: currentAddressParameters(coordinate: coordinate),
                   encoding: URLEncoding.default,
                   headers: headers)
        .validate(statusCode: 200..<300)
        .responseDecodable(of: CurrentAddressResult.self) { response in
            let result = response.result
            switch result {
            case .success(let result):
                completion(result)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    /// 키워드로 검색하기 (상호명 등을 검색)
    func searchKeyword(with keyword: String, coordinate: Coordinate, page: Int, isAccuracy: Bool = true, completion: @escaping (KeywordResult?) -> Void) {
        let url = host + "search/keyword.json"
        
        AF.request(url,
                   method: .get,
                   parameters: keywordParameters(query: keyword,
                                                 coordinate: coordinate,
                                                 page: page,
                                                 isAccurancy: isAccuracy),
                   encoding: URLEncoding.default,
                   headers: headers)
        .validate(statusCode: 200..<600)
        .responseDecodable(of: KeywordResult.self) { response in
            let result = response.result
            switch result {
            case .success(let searchResult):
                guard let totalPage = searchResult.meta?.pageableCount,
                      totalPage >= page else {
                    print("HTTP Client - searchKeyword 총 데이터 페이지수 : \(String(describing: searchResult.meta?.pageableCount))")
                    completion(nil)
                    return
                }
                completion(searchResult)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    // MARK: - Refactor
    
    /// 해당 위치에 대한 데이터 카카오맵 크롤링해서 가져옴 Observable<TargetPlaceDetail>
    func getDetailDataObservable(placeCode: String) -> Observable<TargetPlaceDetail>  {
        let url = "https://place.map.kakao.com/main/v/" + placeCode
        return Observable.create { emitter in
            let task = AF.request(url,
                                  method: .get,
                                  encoding: URLEncoding.default)
                .responseDecodable(of: TargetPlaceDetail.self) { response in
                    let result = response.result
                    switch result {
                    case .success(let results):
                        emitter.onNext(results)
                        return
                    case .failure(let error):
                        emitter.onError(error)
                    }
                }
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    /// 주소로 검색하기 (건물명, 도로명, 지번, 우편번호 및 좌표)
    func getLocationAddressObservable(coordinate: Coordinate) -> Observable<CurrentAddressResult> {
        let url = host + "geo/coord2regioncode.json"
        return Observable.create { [weak self] emitter in
            let task = AF.request(url,
                                  method: .get,
                                  parameters: self?.currentAddressParameters(coordinate: coordinate),
                                  encoding: URLEncoding.default,
                                  headers: self?.headers)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: CurrentAddressResult.self) { response in
                    let result = response.result
                    switch result {
                    case .success(let result):
                        emitter.onNext(result)
                    case .failure(let error):
                        emitter.onError(error)
                    }
                }
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    /// 키워드로 검색하기 (상호명 등을 검색)
    func searchKeywordObservable(with keyword: String, coordinate: Coordinate, page: Int, isAccuracy: Bool = true) -> Observable<KeywordResult> {
        let url = host + "search/keyword.json"
        return Observable.create { [weak self] emitter in
            let task = AF.request(url,
                                  method: .get,
                                  parameters: self?.keywordParameters(query: keyword,
                                                                      coordinate: coordinate,
                                                                      page: page,
                                                                      isAccurancy: isAccuracy),
                                  encoding: URLEncoding.default,
                                  headers: self?.headers)
                .validate(statusCode: 200..<600)
                .responseDecodable(of: KeywordResult.self) { response in
                    let result = response.result
                    switch result {
                    case .success(let searchResult):
                        emitter.onNext(searchResult)
                    case .failure(let error):
                        emitter.onError(error)
                    }
                }
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    func getDirection(startPoint: Coordinate, destination: Coordinate) -> Observable<DestinationResult> {
        let url = "https://apis-navi.kakaomobility.com/v1/directions"
        return Observable.create { [weak self] emitter in
            let task = AF.request(url,
                                  method: .get,
                                  parameters: self?.directionParameters(startPoint: startPoint,
                                                                        destination: destination),
                                  encoding: URLEncoding.default,
                                  headers: self?.headers)
                .validate(statusCode: 200..<600).responseDecodable(of: DestinationResult.self) { response in
                    let result = response.result
                    switch result {
                    case.success(let direction):
                        emitter.onNext(direction)
                    case .failure(let error):
                        emitter.onError(error)
                    }
                }
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
