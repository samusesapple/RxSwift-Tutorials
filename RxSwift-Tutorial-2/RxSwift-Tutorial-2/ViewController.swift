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
    
    var imageURL: PublishSubject<String?> = PublishSubject<String?>()
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindInput()
        bindOutput()
    }
    
    // MARK: - Bind
    func bindInput() {
        resumeButton.rx.tap.subscribe { _ in
            HttpClient.shared.getImageURL()
                .bind(to: self.imageURL)
                .disposed(by: self.disposeBag)
        }
        .disposed(by: disposeBag)
    }
    
    func bindOutput() {
        // label text, imageView image
//        imageURL
//            .filter({ $0 != nil })
//            .map({ URL(string: $0!)! })
//            .map(self.rxImageLoader)
//            .observe(on: MainScheduler.asyncInstance)
        
        imageURL.subscribe(onNext: { urlString in
            guard let urlString = urlString else { return }
            self.rxImageLoader(URL(string: urlString)!)
                .asObservable()
                .observe(on: MainScheduler.asyncInstance)
                .subscribe { image in
                    self.imageView.image = image
                    self.mainLabel.text = "FETCHED!"
                }
                .disposed(by: self.disposeBag)
        })
        .disposed(by: disposeBag)
    }
    
    // MARK: - Logics
    
    private func rxImageLoader(_ url: URL) -> Observable<UIImage?> {
        return Observable.create { emitter in
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

