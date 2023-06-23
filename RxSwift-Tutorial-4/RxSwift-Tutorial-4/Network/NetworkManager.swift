//
//  NetworkManager.swift
//  RxSwift-Tutorial-4
//
//  Created by Sam Sung on 2023/06/23.


import Foundation
import Alamofire
import RxSwift

struct NetworkManager {
    
    static let shared = NetworkManager()
    
    private var header: HTTPHeaders = [
        "X-Naver-Client-Id": "mC2SWXljwWXT8G4GC7Vp",
        "X-Naver-Client-Secret": "XgZuZpqCrJ"
    ]
    
    private init() { }
    
    
    // MARK: - Parameters
    
    private func searchParameters(_ keyword: String) -> [String: Any] {
        [
            "query" : keyword.utf8,
            "display" : "20"
        ]
    }
    
    // MARK: - Get

    func getSearchResult(_ keyword: String) -> Observable<[Item]?> {
        return Observable.create { emitter in
        let request = AF.request(URL(string: "https://openapi.naver.com/v1/search/blog.json")!,
                                              method: .get,
                                              parameters: searchParameters(keyword),
                                              headers: header)
        .responseDecodable(of: Search.self) { response in
            switch response.result {
            case .success(let search):
                emitter.onNext(search.items)
            case .failure(let error):
                emitter.onError(error)
            }
        }
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
