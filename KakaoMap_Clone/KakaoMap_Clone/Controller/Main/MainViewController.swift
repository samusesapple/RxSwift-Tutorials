//
//  ViewController.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/21.
//

import CoreLocation
import ReactorKit
import RxSwift
import RxCocoa
import UIKit

final class MainViewController: UIViewController, View {
    
    private var reactor: MainViewReactor!
    
    var disposeBag: DisposeBag
    
    private var userLocationRelay: PublishRelay<Coordinate> = PublishRelay()
    private var mapCenterRelay: PublishRelay<Coordinate> = PublishRelay()
    
    // MARK: - Components
    
    private let menuVC = MenuViewController()
    
    private let mapView: MTMapView = {
        let mapView = MTMapView()
        mapView.baseMapType = .standard
        return mapView
    }()
    
    private let currentLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.setImage(UIImage(systemName: "location.north.circle")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    
    private let searchBarView = CustomSearchBarView(placeholder: "장소를 검색해주세요", needBorderLine: false)
    
    // MARK: - Lifecycle
    
    init() {
        self.reactor = MainViewReactor(location: Coordinate(longtitude: 37.123,
                                                            latitude: 36.123))
        self.disposeBag = DisposeBag()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        
        menuVC.delegate = self
        mapView.delegate = self
        
        setLocationManager()
        setAutolayout()
        setActions()
        setMapView()
        
        bind(reactor: reactor)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - Actions
    
    func bind(reactor: MainViewReactor) {
        bindActions(reactor)
        bindStates(reactor)
    }
    
    private func bindActions(_ reactor: MainViewReactor) {
        // searchBar tapped
        searchBarView.getSearchBar().searchTextField.rx.controlEvent([.touchUpInside])
            .map({ MainViewReactor.Action.searchBarDidTapped })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // menuButton tapped
        searchBarView.getMenuButton().rx.tap
            .map({ MainViewReactor.Action.menuButtonDidTapped })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // mapView did moved
    }
    
    private func bindStates(_ reactor: MainViewReactor) {
        // user current location
        reactor.state
            .map({ $0.userLocationCoordinate })
            .bind(to: userLocationRelay)
            .disposed(by: disposeBag)
        
        // map center coordinate
        reactor.state
            .map({ $0.mapCenterCoordinate })
            .bind(to: mapCenterRelay)
            .disposed(by: disposeBag)
        
        // present searchVC
        reactor.state
            .map({ $0.shouldStartSearching })
            .filter({ $0 == true })
            .bind { _ in
                let searchVC = SearchViewController()
                self.navigationController?.pushViewController(searchVC, animated: true)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map({ $0.menuIsOpend })
            .bind(onNext: { [weak self] opened in
                self?.bindMenuStatus(open: opened)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindMenuStatus(open: Bool) {
        let translationX = open ? 0 : menuVC.view.frame.width
        let backgroundcolor = open ? UIColor.clear : UIColor(red: 33/255,
                                                               green: 33/255,
                                                               blue: 33/255,
                                                               alpha: 0.8)
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: .curveEaseInOut) { [weak self] in
            self?.menuVC.view.transform = CGAffineTransform(translationX: translationX, y: 0)
        } completion: { [weak self] done in
            if done {
                self?.menuVC.view.backgroundColor = backgroundcolor
                if open {
                    self?.menuVC.menuContainer.transform = CGAffineTransform(translationX: translationX, y: 0)
                }
            }
            return
        }
    }
    
    @objc private func showCurrentLocation() {
        print("현재 위치로 이동")
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            if LocationManager.shared.authorizationStatus == .authorizedAlways || LocationManager.shared.authorizationStatus == .authorizedWhenInUse {
                guard let currentCoordinate = LocationManager.shared.location?.coordinate else { return }
                let currentLongtitude = currentCoordinate.longitude
                let currentLatitude = currentCoordinate.latitude
                DispatchQueue.main.async {
                    self?.mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: currentLatitude,
                                                                                  longitude: currentLongtitude)), animated: true)
                }
            }
        }
    }
    
    @objc private func swipedToOpenMenu() {
        print("SWIPE")
        
    }
    
    // MARK: - Helpers
    
    private func setAutolayout() {
        view.addSubview(mapView)
        mapView.setDimensions(height: view.frame.height, width: view.frame.width)
        
        mapView.addSubview(searchBarView)
        searchBarView.setDimensions(height: 46, width: view.frame.width - 30)
        searchBarView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 10)
        searchBarView.centerX(inView: mapView)
        
        
        mapView.addSubview(currentLocationButton)
        currentLocationButton.setDimensions(height: 50, width: 50)
        currentLocationButton.anchor(left: mapView.leftAnchor, bottom: mapView.bottomAnchor, paddingLeft: 18, paddingBottom: 40)
        DispatchQueue.main.async { [weak self] in
            self?.currentLocationButton.makeRounded()
        }
    }
    
    private func setActions() {
        currentLocationButton.addTarget(self, action: #selector(showCurrentLocation), for: .touchUpInside)
        //        searchBarView.getMenuButton().addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        //        searchBarView.getSearchBar().searchTextField.addTarget(self, action: #selector(searchBarTapped), for: .editingDidBegin)
        hideKeyboardWhenTappedAround()
    }
    
    // 위치 사용 권한 허용 체크 및 locationManager 세팅 및 searchBar - placeholder 현재 위치로 세팅
    private func setLocationManager() {
        if LocationManager.shared.authorizationStatus != .authorizedAlways || LocationManager.shared.authorizationStatus != .authorizedWhenInUse {
            LocationManager.shared.requestWhenInUseAuthorization()
        }
        LocationManager.shared.delegate = self
        LocationManager.shared.desiredAccuracy = kCLLocationAccuracyBest  // 배터리 최적화
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.mapView.currentLocationTrackingMode = .onWithoutHeading
            guard let location = LocationManager.shared.location?.coordinate
            else {
                print("location update 아직 안된 상태")
                return
            }
            self?.reactor = MainViewReactor(location: Coordinate(longtitude: location.longitude,
                                                                 latitude: location.latitude))
        }
    }
    
    private func setMapView() {
        // mainVC 위에 menuVC 쌓기
        self.addChild(menuVC)
        self.view.addSubview(menuVC.view)
        menuVC.didMove(toParent: self)
        // menuVC 숨기기
        menuVC.view.transform = CGAffineTransform(translationX: -menuVC.view.frame.width, y: 0)
    }
    
    // 사용자의 환경설정 - 위치 허용으로 안내
    private func showRequestLocationServiceAlert() {
        let requestLocationServiceAlert = UIAlertController(title: "위치 정보 이용", message: "위치 서비스를 사용할 수 없습니다.\n디바이스의 '설정 > 개인정보 보호'에서 위치 서비스를 켜주세요.", preferredStyle: .alert)
        let presentSettings = UIAlertAction(title: "설정으로 이동", style: .destructive) { _ in
            if let appSetting = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSetting)
            }
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        requestLocationServiceAlert.addAction(cancel)
        requestLocationServiceAlert.addAction(presentSettings)
        
        present(requestLocationServiceAlert, animated: true)
    }
}

// MARK: - CLLocationManagerDelegate

extension MainViewController: CLLocationManagerDelegate {
    
    // 권한설정 변경된 경우 실행
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("GPS 권한설정 허용됨")
            LocationManager.shared.startUpdatingLocation()
            
        case .restricted, .notDetermined:
            print("GPS 권한설정 X")
            LocationManager.shared.requestWhenInUseAuthorization()
            
        case .denied:
            print("GPS 권한설정 거부됨")
            showRequestLocationServiceAlert()
        default:
            print("요청")
        }
    }
}

// MARK: - MTMapViewDelegate

extension MainViewController: MTMapViewDelegate {
    func mapView(_ mapView: MTMapView!, finishedMapMoveAnimation mapCenterPoint: MTMapPoint!) {
        // 맵 이동되면 이동된 위치 세팅 필요
        //        viewModel.getAddressDetailResult(lon: mapCenterPoint.mapPointGeo().longitude,
        //                                         lat: mapCenterPoint.mapPointGeo().latitude)
    }
    // 메모리 차지가 많을 경우, 캐시 정리
    override func didReceiveMemoryWarning() {
        mapView.didReceiveMemoryWarning()
    }
}

// MARK: - MenuViewControllerDelegate

extension MainViewController: MenuViewControllerDelegate {
    func needToPresent(viewController: FavoriteViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func needToCloseMenuView() {
        //        viewModel.needToOpenMenu = false
    }
}
