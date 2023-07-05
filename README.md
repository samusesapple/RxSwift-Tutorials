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
- SnapKit, Then, Alamofire 같이 활용하기
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
<br>

### 6. 가상 입출금 앱
---
#### * 구현 목표
- 입금, 출금, 입출금 내역 확인 가능한 Mock 입출금 앱 만들기
- ReactorKit을 활용한 MVVM 패턴
- 반응형 데이터 전달 구현
- DI 
- Unit Test
<br>

#### * 구조
<img width="1043" alt="image" src="https://github.com/samusesapple/RxSwift-Tutorials/assets/126672733/ee7bd2a8-36e6-45ad-90cd-ff6b09af99a3">

![image](https://github.com/samusesapple/RxSwift-Tutorials/assets/126672733/b9e488e0-2bf5-4faf-b593-3c24fdc24b7a)
<br>

#### * Unit Test
* Unit Test 형식:
  
        1. SUT : System Under Text (테스트 대상)
        2. 테스트 시나리오 작성 및 테스트 검증 : GWT 형식 (Given, When, Then 형식)
  
* SUT: TransactionViewController (입출금 작업이 일어나기에 비즈니스 로직이 가장 많이 일어나는 View에 Reactor에 대한 단위 테스트 실행)
* DI(의존성 주입): BankAccount 프로토콜 생성하여 해당 프로토콜을 채택한 모든 객체가 Reactor(ViewModel)의 생성자에 들어갈 수 있도록 Dependency Injection 완료 된 상태로 테스트 진행
* MockData: Unit Test의 참거짓을 비교 판단할 데이터 대상이 필요하기에 BankAccount 프로토콜을 채택한 MockData 객체 생성 및 사용하여 테스트 진행 <br>
    <img width="276" alt="image" src="https://github.com/samusesapple/RxSwift-Tutorials/assets/126672733/3b53bdb5-f9d4-4038-956a-5720317b55e0">
    <br>

    <img width="566" alt="image" src="https://github.com/samusesapple/RxSwift-Tutorials/assets/126672733/319146fe-cda3-486a-ac79-bf65054c60ed">
    <br>

1. View -> Reactor (View로부터 Action 전달 받는 것에 대한 단위 테스트)
    <img width="623" alt="image" src="https://github.com/samusesapple/RxSwift-Tutorials/assets/126672733/2c158efd-f656-426a-a575-6075b31ac208">

2. Reactor (Action에 대해 처리할 작업, Muataion에 따른 State 변경에 대한 단위 테스트)
    <img width="596" alt="image" src="https://github.com/samusesapple/RxSwift-Tutorials/assets/126672733/0cdeea7e-0ac4-45fc-8390-316bd20d9f39">

3. Reactor -> View (Reactor의 상태값, State를 View가 잘 구독하고 있는지에 대한 단위 테스트)
   <img width="555" alt="image" src="https://github.com/samusesapple/RxSwift-Tutorials/assets/126672733/e79adaed-1528-4e7a-b854-84b60eea4517">
<br>

#### * 데이터 전달 로직
1. currentBalance : NotificationCenter 활용;
   1. TransactionReactor : 입출금 action이 일어날 때마다 valueDidChange에 대해 true 값을 보냄 
   2. TransactionVC : Reactor의 valueDidChanged를 구독, true 일 경우 currentBalance에 대한 Notification post
   3. MainVC : currentBalance에 대한 NotificationCenter의 옵저버로 등록된 상태. 노티 받을 때마다 Action.currentBalanceDidChanged에 바뀐 값을 바인딩
   4. MainReactor : action에 대한 mutation 진행, state값 변경
   5. MainVC : state값 구독하고 있으므로 UI 변경
   * TransactionReactor
   ```
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .deposit(let value):
            return Observable.concat([
                Observable.just(.valueDidChanged(true)),
                Observable.just(.increaseBalance(value)),
                Observable.just(.addTransactionHistory(.deposit(value))),
                Observable.just(.valueDidChanged(false))
            ])
        case .withdraw(let value):
            return Observable.concat([
                Observable.just(.valueDidChanged(true)),
                Observable.just(.decreaseBalance(value)),
                Observable.just(.addTransactionHistory(.withdraw(value))),
                Observable.just(.valueDidChanged(false))
            ])
        }
    }
   ```
   * TransactionVC
   ```
   reactor.state
       .map({ $0.statusDidChanged })
       .filter({ $0 != false })
       .map({ [weak self] _ in
         self!.balanceView.balanceLabel.text!
       })
       .subscribe(onNext: { value in
          NotificationCenterManager.postCurrentBalanceChangeNotification(value: Int(value)!)
       })
       .disposed(by: disposeBag)
   ```
2. historyList : push할 Reactor의 State를 구독하는 방식 활용
   1. MainReactor : historyListDidUpdated([Transaction]) 라는 액션을 받아 State를 mutating 하도록 로직 구현
   2. MainVC : TransactionVC를 push 하는 시점에 transactionVC.reactor.state 중 transactionHistory 구독, MainReactor의 history와 일치하지 않는지 여부 판단 후 historyListDidUpdated 액션으로 newValue 전달
   3. TransactionVC에서 값이 바뀌면 이를 구독하고 있는 MainVC에게 저절로 데이터가 전달됨.
   4. MainVC에 전달된 데이터는 Reactor에게 Action으로써 또 전달됨. Reactor는 Action에 대해 State 변경함. MainVC는 변경된 State에 대한 UI 작업 처리함.
   * MainReactor
   ```
       func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        ...
        case .historyListDidUpdated(let newHistoryList):
            return Observable.just(.updateHistoryList(newHistoryList))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        ...
        case .updateHistoryList(let newHistoryList):
            self.account.history = newHistoryList
            return state
        }
    }
   ```
   * MainVC
   ```
    actionButton.rx.tap
       .map({ reactor.transactionReactor })
       .map({
           let transactionVC = TransactionViewController()
           transactionVC.reactor = $0
           return transactionVC
            })
        // transactionVC push하기 전에 transactionVC state 구독 시작
            .subscribe(onNext: { [weak self] transActionVC in
                transActionVC.reactor?.state
                    .map({ $0.transactionHistory })
                    .filter({ $0 != reactor.currentState.historyList })
        // MainReactor의 Action에 바인딩
                    .map({ Reactor.Action.historyListDidUpdated($0) })
                    .bind(to: reactor.action)
                    .disposed(by: self!.disposeBag)
                
        self?.navigationController?
           .pushViewController(transActionVC, animated: true)
        })
       .disposed(by: disposeBag)
   ```
<br>


#### * 구현 결과
![Simulator Screen Recording - iPhone 14 Pro - 2023-07-05 at 17 11 49](https://github.com/samusesapple/RxSwift-Tutorials/assets/126672733/10c05f31-860f-465d-ad50-38a16c0bb826) ![Simulator Screen Recording - iPhone 14 Pro - 2023-07-05 at 17 14 15](https://github.com/samusesapple/RxSwift-Tutorials/assets/126672733/b33d3b8b-76e9-4364-ad26-affbb5debfb6)
<br>
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
- RxSwift-Tutorial-6 (가상 입출금 앱) : ReactorKit https://github.com/ReactorKit/ReactorKit 
