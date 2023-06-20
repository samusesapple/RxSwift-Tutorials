# RxSwift-Tutorials
### 목적
---
RxSwift 기능 학습
<br>
<br>
<br>

### 1. ID & PW 매칭
---
#### * 구현 목표
1. idInputField.text : @과.com이 포함 된 경우, 오른쪽의 bullet 색상이 '초록색'으로 바뀐다.
2. pwInputField.text : 6글자 이상인 경우, 오른쪽의 bullet 색상이 '초록색'으로 바뀐다.
3. ID와 PW의 bullet이 둘 다 초록색인 경우, LOGIN 버튼이 파란색으로 변하고 활성화 된다.
4. ID와 PW의 text가 각각 'id@gmail.com', 'password'와 일치하는 경우 로그인 버튼을 통해 다음 화면으로 이동할 수 있다.
<img width="594" alt="image" src="https://github.com/samusesapple/RxSwift-Tutorials/assets/126672733/5522e339-a489-444c-bbc1-984c28d77654">
<br>

#### * 구현 방법 및 로직
* 로직
    ```
        private func checkEmailValid(_ email: String) -> Bool {
            return email.contains("@") && email.contains(".com")
        }

        private func checkPasswordValid(_ password: String) -> Bool {
            return password.count > 5
        }
    
        private func changeValidViewStatus(_ view: UIView, status valid: Bool) {
            if valid {
                view.backgroundColor = .green
            } else {
                view.backgroundColor = .red
            }
        }
    
        override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
            return matchStatus
        }
    ```
<br>

 * 외부 변수 생성
     ```
        let idValid: BehaviorSubject<Bool> = BehaviorSubject(value: false)
        let idString: BehaviorSubject<String> = BehaviorSubject(value: "")
        
        let passwordValid: BehaviorSubject<Bool> = BehaviorSubject(value: false)
        let passwordString: BehaviorSubject<String> = BehaviorSubject(value: "")
    
        var matchStatus: Bool = false
    ```
<br>

 * Bind Input
    ```
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
        ```
<br>

 * Bind Output
     ```
        private func bindOutput() {
            // bullets - id
            idValid.subscribe(onNext: { valid in
                self.changeValidViewStatus(self.idValidView,
                                           status: valid)
            })
                .disposed(by: disposeBag)
        
            // bullets - password
            passwordValid.subscribe(onNext: { valid in
                self.changeValidViewStatus(self.pwValidView,
                                           status: valid)
            })
                .disposed(by: disposeBag)
        
            // login Button
            Observable.combineLatest(idValid, passwordValid, resultSelector: { $0 && $1 })
                .subscribe { enabled in
                    if enabled {
                        self.loginButton.backgroundColor = .systemBlue
                    } else {
                        self.loginButton.backgroundColor = .lightGray
                    }
                }
                .disposed(by: disposeBag)
        
            // check ID & PW
            Observable.combineLatest(idString, passwordString)
                .map({ $0 == "id@gmail.com" && $1 == "password" })
                .subscribe { self.matchStatus = $0 }
                .disposed(by: disposeBag)
        }
     ```
<br>
<br>
<br>

#### * 구현 결과 
![Simulator Screen Recording - iPhone 14 Pro - 2023-06-18 at 15 47 19](https://github.com/samusesapple/RxSwift-Tutorials/assets/126672733/72a14ef6-3f28-47c0-9bc5-7b41d99dfcd4)
![Simulator Screen Recording - iPhone 14 Pro - 2023-06-18 at 15 47 49](https://github.com/samusesapple/RxSwift-Tutorials/assets/126672733/4e222eb0-d51d-46d7-983b-a55bb7dda8fa)
<br>
<br>
<br>

### 2. 랜덤 고양이 사진 받기
---
#### * 구현 목표
* resume 버튼을 누르면 고양이 사진을 받는다. 
* stop 버튼을 누르면 하얀 화면을 띄운다.

#### * 구현 방법 및 로직
* 구현 로직
  1. resume 버튼을 누르면 https://thecatapi.com/의 API 서버로부터 고양이 사진 URL을 랜덤으로 받는다.
  2. 서버로부터 받은 URL 데이터를 외부 변수에 저장한다.
  3. 외부 변수에 저장된 URL 데이터를 통해 이미지를 다운받는다.
  4. 이미지가 다 다운받아지면 화면에 띄운다.
<br>

 * 로직
   ```
    @IBAction func resumeButtonTapped(_ sender: Any) {
        HttpClient.shared.getImageURL()
            .bind(to: imageURL)
            .disposed(by: disposeBag)
        
        imageURL.subscribe { string in
            self.rxImageLoader(string)
                .observe(on: MainScheduler.asyncInstance)
                .bind(onNext: { self.imageView.image = $0 })
                .disposed(by: self.disposeBag)
        }
        .disposed(by: disposeBag)
    }
    
    @IBAction func stopButtonTapped(_ sender: Any) {
        disposeBag = DisposeBag()
        imageView.image = nil
    }
   ```
   <br>
* 외부 변수
  ```
      var imageURL: PublishSubject<String?> = PublishSubject<String?>()
  ```
<br>

* 네트워킹
  ```
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

  ```
<br>

 * Image Loader
   ```
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
   ```
   <br>

#### * 구현 결과
![ezgif-4-a830d51106](https://github.com/samusesapple/RxSwift-Tutorials/assets/126672733/5a73759e-d38e-4b80-9265-964e96c34c87)
<br>
<br>
<br>


### 출처 및 참고 자료
---
- RxSwift-Tutorial-1 (아이디 비밀번호 매칭) : https://github.com/iamchiwon/RxSwift_In_4_Hours
