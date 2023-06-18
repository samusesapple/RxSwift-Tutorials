//
//  ViewController.swift
//  RxSwift-Tutorial
//
//  Created by Sam Sung on 2023/06/17.
//

import RxCocoa
import RxSwift
import UIKit

class ViewController: UIViewController {
    var disposeBag = DisposeBag()

    let idValid: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    let idString: BehaviorSubject<String> = BehaviorSubject(value: "")
    
    let passwordValid: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    let passwordString: BehaviorSubject<String> = BehaviorSubject(value: "")
    
    var matchStatus: Bool = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindInput()
        bindOutput()
    }

    // MARK: - IBOutlet

    @IBOutlet var idField: UITextField!
    @IBOutlet var pwField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var idValidView: UIView!
    @IBOutlet var pwValidView: UIView!

    // MARK: - Bind
    
    private func bindInput() {
   // input : id 입력, pw 입력
        idField.rx.text.orEmpty
            .bind(to: idString) // idField의 text를 외부변수에 전달
            .disposed(by: disposeBag)
        
        idString // idField의 text를 전달받은 외부변수
            .map(checkEmailValid) // 해당 변수 값의 email valid 여부 체크 -> bool
            .bind(to: idValid) // vaild 여부에 대한 결과를 외부 변수에 전달
            .disposed(by: disposeBag)
        
        pwField.rx.text.orEmpty
            .bind(to: passwordString) // pwField의 text를 외부변수에 전달
            .disposed(by: disposeBag)
        
        passwordString // pwField의 text를 전달받은 외부변수
            .map(checkPasswordValid) // 해당 변수 값의 password valid 여부 체크 -> bool
            .bind(to: passwordValid) // vaild 여부에 대한 결과를 외부 변수에 전달
            .disposed(by: disposeBag)
    }
    
    private func bindOutput() {
        // bullets - id
        idValid.subscribe(onNext: { [weak self] valid in
            self?.changeValidViewStatus(self?.idValidView,
                                       status: valid)
        })
            .disposed(by: disposeBag)
        
        // bullets - password
        passwordValid.subscribe(onNext: { [weak self] valid in
            self?.changeValidViewStatus(self?.pwValidView,
                                       status: valid)
        })
            .disposed(by: disposeBag)
        
        // login Button
        Observable.combineLatest(idValid, passwordValid, resultSelector: { $0 && $1 })
            .subscribe { [weak self] enabled in
                if enabled {
                    self?.loginButton.backgroundColor = .systemBlue
                } else {
                    self?.loginButton.backgroundColor = .lightGray
                }
            }
            .disposed(by: disposeBag)
        
        // check ID & PW
        Observable.combineLatest(idString, passwordString)
            .map({ $0 == "id@gmail.com" && $1 == "password" })
            .subscribe { [weak self] status in
                self?.matchStatus = status
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Logic

    private func checkEmailValid(_ email: String) -> Bool {
        return email.contains("@") && email.contains(".com")
    }

    private func checkPasswordValid(_ password: String) -> Bool {
        return password.count > 5
    }
    
    private func changeValidViewStatus(_ view: UIView?, status valid: Bool) {
        guard let view = view else { return }
        if valid {
            view.backgroundColor = .green
        } else {
            view.backgroundColor = .red
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return matchStatus
    }

}
