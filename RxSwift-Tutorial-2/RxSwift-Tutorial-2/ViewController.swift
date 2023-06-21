//
//  ViewController.swift
//  RxSwift-Tutorial-2
//
//  Created by Sam Sung on 2023/06/18.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    // MARK: - Properties
    private var disposeBag = DisposeBag()
    private var disposable: Disposable?
    
    var imageURL = PublishSubject<String?>()
    
    let sampleView = UIView()
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    // MARK: - IBActions
    
    @IBAction func resumeButtonTapped(_ sender: Any) {
        HttpClient.shared.getImageURL()
            .bind(to: imageURL)
            .disposed(by: disposeBag)
                
        //        imageURL.subscribe { string in
        //            self.rxImageLoader(string)
        //                .observe(on: MainScheduler.asyncInstance)
        //                .bind(onNext: { self.imageView.image = $0 })
        //                .disposed(by: self.disposeBag)
        //        }
        //        .disposed(by: disposeBag)
        

    }
    
    @IBAction func stopButtonTapped(_ sender: Any) {
        disposeBag = DisposeBag()
        imageView.image = nil
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _ = imageURL
            .observe(on: SerialDispatchQueueScheduler(qos: .userInitiated))
            .map({ self.rxImageLoader($0) })
            .flatMap ({ $0 })
            .observe(on: MainScheduler.asyncInstance)
            .bind(onNext: { self.imageView.image = $0 })
//            .disposed(by: disposeBag)
    }
    
    
    // MARK: - Helpers
    
    private func rxImageLoader(_ urlString: String?) -> Observable<UIImage?> {
        return Observable.create { emitter in
            let url = URL(string: urlString!)!
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if error != nil {
                    emitter.onError(error!)
                    return
                }
                guard let data = data else {
                    emitter.onCompleted()
                    return
                }
                
                let image = UIImage(data: data)
                emitter.onNext(image)
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
}

