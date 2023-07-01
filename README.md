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

### 3. 멤버 리스트 tableView에 띄우기 (feat. Alamofire)
---
#### * 구현 목표
* Alamofire + RxSwift를 통한 보다 더 깔끔한 네트워킹 작업 구현
<br>

#### * 구현 방법 및 로직
* 로직
  1. viewDidLoad() 시점에 서버로부터 멤버 데이터를 배열 형태로 받는다.
  2. 비동기 작업이 완료되면 tableView를 reload 한다.
  3. tableView dataSource cellForRowAt에 indexPath.row를 사용하여 각각의 row에 해당되는 멤버의 데이터를 셀에 전달한다.
  4. 전달받은 데이터로 셀의 UI를 구성한다.
  <br>
  
  * viewDidLoad()
    ```
    func setData() {
        NetworkManager.shared.getMembers()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] members in
                self?.data = members
                self?.tableView.reloadData()
            }
            .disposed(by: disposeBag)
    }
    ```
 <br>
 
* 네트워킹
  * Data Loader (Alamofire)
  ```
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
  ```
  <br>
  
  * Image Loader (Alamofire)
  ```
      func loadImage(from url: String) -> Observable<UIImage?> {
        return Observable.create { emitter in
            let request = AF.request(URL(string: url)!)
                .response { response in
                    switch response.result {
                    case .success(let data):
                        emitter.onNext(UIImage(data: data!))
                    case .failure(let error):
                        emitter.onError(error)
                    }
                }
            return Disposables.create {
                request.cancel()
            }
        }
    }
  ```
<br>

#### * 구현 결과 
![Simulator Screen Recording - iPhone 14 Pro - 2023-06-22 at 19 22 59](https://github.com/samusesapple/RxSwift-Tutorials/assets/126672733/f4bedcda-deb4-4f06-ab9a-1d5da5b0469b)
<br>
<br>
<br>

### 4. 검색 포털 만들기
---
#### * 구현 목표
- RxSwift를 활용한 검색 포털 만들기
- SnapKit, Then, Alamofire, Kingfisher 같이 활용하기
- Naver 검색 API 활용하기
<br>

#### * 구현 로직
* 로직
    1. searchBar의 text를 구독하여 변경되는 값을 외부 변수에 저장
    2. 외부 변수의 값이 변경 될 때마다 네트워킹 요청
    3. 네트워킹을 통해 나온 결과값을 tableView에 display
    4. 해당되는 셀의 url을 detailVC에 전달
    5. detailVC - 전달받은 url을 통해 해당 웹페이시 webview에 띄우기
<br>

#### * 구현 결과
![Simulator Screen Recording - iPhone 14 - 2023-06-27 at 23 39 25](https://github.com/samusesapple/RxSwift-Tutorials/assets/126672733/d2bba83b-246b-40f9-9aa7-114d1ef9c159)
<br>
<br>
<br>

### 5. 더치페이 계산기 
---
#### * 구현 목표
- 애플 전화기 theme의 더치페이 계산기 앱 만들기
- MVVM 패턴
- Unit test 구현
- RxSwift로 진행하는 첫 미니 토이 프로젝트
<br>

#### * 구조
<img width="981" alt="image" src="https://github.com/samusesapple/RxSwift-Tutorials/assets/126672733/973318e0-dbbf-4629-b302-4941530d8c96">
<br>

#### * 문제상황 및 해결과정
1. UITextField.rx.text는 유저가 직접 키보드로 텍스트필드를 선택해서 입력한 이벤트만 방출한다. 따라서 앱 상의 숫자패드를 입력하여 textField.text를 변경해도 해당 이벤트는 방출되지 않는다. <br>

* 아이디어 로직: <br>
    1. VC : 버튼이 눌리면 외부변수 buttonSubject: PublishSubject<ButtonCommand> 에 어떤 버튼이 눌렸는지를 담는다.
    2. VC : buttonSubject를 구독한 후, ButtonCommand의 case에 따라 분기처리 한다.
    3. VC: 각 case에 필요한 Observer를 viewModel에 요청한다.
    4. viewModel에서는 VC에게 줄 Observer를 생성해준다.
    5. viewModel로부터 받은 Observer를 각각의 외부변수(Subject)에 바인딩한다.
    6. viewModel은 각 외부변수(Subject)를 조합하여 Output을 VC에게 준다.
    7. viewModel로부터 받은 Output으로 UI를 그린다.
<br>

* 코드 :
> ViewController
<img width="604" alt="image" src="https://github.com/samusesapple/RxSwift-Tutorials/assets/126672733/56e2c8c2-1a99-40e7-befd-ac35e094af92">
<img width="478" alt="image" src="https://github.com/samusesapple/RxSwift-Tutorials/assets/126672733/df033620-2a48-49ed-9a95-75d794338ca3">
<img width="719" alt="image" src="https://github.com/samusesapple/RxSwift-Tutorials/assets/126672733/83241a4c-240b-45c3-ac02-32e6868414ff">
<br>
<br>

> ViewModel
 <img width="615" alt="image" src="https://github.com/samusesapple/RxSwift-Tutorials/assets/126672733/8a752240-896a-4b0c-83bc-5782e0b5c326">
<img width="546" alt="image" src="https://github.com/samusesapple/RxSwift-Tutorials/assets/126672733/b534d0bb-b8b4-455d-9b72-bda24f32feec">

<br>
<br>

#### * Unit Test 과정
    1. SUT(테스트 대상) : CalculatorViewModel
    2. 테스트 시나리오 작성 및 테스트 검증 (GWT 형식) : 'totalAmount: 1000, personCount: 4' 일 경우의 output을 검증하는 test case 작성 및 검증 
<br>
<img width="627" alt="image" src="https://github.com/samusesapple/RxSwift-Tutorials/assets/126672733/ef7f0f88-0f7f-41ae-b4d0-028189f13410">
<br>
<br>

#### * 구현 결과
![Simulator Screen Recording - iPhone 14 Pro - 2023-06-30 at 16 26 34](https://github.com/samusesapple/RxSwift-Tutorials/assets/126672733/f6b93620-c10d-4454-9d29-da338c26145a)
<br>
<br>


### 출처 및 참고 자료
---
- RxSwift-Tutorial-1 (아이디 비밀번호 매칭) : 
    https://github.com/iamchiwon/RxSwift_In_4_Hours
- RxSwift-Tutorial-3 (멤버 리스트 tableView에 띄우기) : 
      https://github.com/iamchiwon/RxSwift_In_4_Hours
- RxSwift-Tutorial-4 (검색 포털 만들기) : 
      네이버 API 공식 개발자 문서 https://developers.naver.com/docs/serviceapi/search/web/web.md#%EC%9B%B9%EB%AC%B8%EC%84%9C
