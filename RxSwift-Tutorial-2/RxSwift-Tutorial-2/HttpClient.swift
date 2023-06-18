//
//  HttpClient.swift
//  RxSwift-Tutorial-2
//
//  Created by Sam Sung on 2023/06/18.
//

import Foundation
import RxSwift
import Alamofire

enum NetworkResult<T> {
    case success(T)
    case failure(Error)
}

struct HttpClient {
    
    static let shared = HttpClient()
    
    private let url = "https://api.thecatapi.com/v1/images/search"
    private var header: HTTPHeaders {
        ["x-api-key" : "live_Kfp5mtn3fKXKJGBYh9vH4JnTksnEt0TIVY1faxZ9dOh63v4uwHiA9Tr7yVFmYQ7t"]
    }
    
    private init() { }
    
    // MARK: - Method
    
    func getImageURL() -> Observable<String?> {
        return Observable.create { observer in
            let request = AF.request(URL(string: url)!,
                                     method: .get,
                                     headers: header)
                .responseDecodable(of: Cat.self) { response in
                    switch response.result {
                    case .success(let data):
                        observer.onNext(data.randomElement()?.url)
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
