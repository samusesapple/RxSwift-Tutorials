//
//  NetworkManager.swift
//  RxSwift-Tutorial-3
//
//  Created by Sam Sung on 2023/06/21.
//

import UIKit
import RxSwift
import Alamofire

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

struct NetworkManager {
    
    static let shared = NetworkManager()
    private init() { }
    
    func getMembers() -> Observable<[Member]> {
        return Observable.create { emitter in
            let requset = AF.request(URL(string: MEMBER_LIST_URL)!,
                                     method: .get)
                .responseDecodable(of: [Member].self) { response in
                    switch response.result {
                    case .success(let data):
                        emitter.onNext(data)
                    case .failure(let error):
                        emitter.onError(error)
                    }
                }
            return Disposables.create {
                requset.cancel()
            }
        }
    }
    
//    func getMembers() -> Observable<[Member]> {
//        return Observable.create { emitter in
//            let task = URLSession.shared.dataTask(with: URL(string: MEMBER_LIST_URL)!) { data, _, error in
//                if let error = error {
//                    emitter.onError(error)
//                    return
//                }
//                guard let data = data,
//                      let members = try? JSONDecoder().decode([Member].self, from: data) else {
//                    emitter.onCompleted()
//                    return
//                }
//
//                emitter.onNext(members)
//                emitter.onCompleted()
//            }
//            task.resume()
//            return Disposables.create {
//                task.cancel()
//            }
//        }
//    }
    
    func loadImage(from url: String) -> Observable<UIImage?> {
        return Observable.create { emitter in
            let task = URLSession.shared.dataTask(with: URL(string: url)!) { data, _, error in
                if let error = error {
                    emitter.onError(error)
                    return
                }
                guard let data = data,
                      let image = UIImage(data: data) else {
                    emitter.onNext(nil)
                    emitter.onCompleted()
                    return
                }
                
                emitter.onNext(image)
                emitter.onCompleted()
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
