//
//  ResultMapViewController.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/25.
//

import CoreLocation
import FirebaseAuth
import JGProgressHUD
import RxSwift
import RxCocoa
import Toast_Swift
import UIKit


protocol ResultMapViewControllerDelegate: AnyObject {
    func needToShowSearchVC()
    func needToShowMainVC()
}

final class ResultMapViewController: UIViewController, CLLocationManagerDelegate {
    
    var viewModel: ResultMapViewModel!
    
    // MARK: - Components
    
    private var mapPoint: MTMapPoint?
    private var poiItem: MTMapPOIItem?
    
    private var polyLine: MTMapPolyline?
    
    private let progressHud = JGProgressHUD(style: .dark)
    
    weak var delegate: ResultMapViewControllerDelegate?
    
    private let mapView: MTMapView = {
        let mapView = MTMapView()
        mapView.baseMapType = .standard
        mapView.backgroundColor = .black
        return mapView
    }()
    
    private lazy var headerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.setupShadow(opacity: 0.3, radius: 1.5, offset: CGSize(width: 0, height: 2.0), color: .black)
        [searchBarView, buttonsView].forEach { view.addSubview($0) }
        return view
    }()
    
    private let searchBarView = CustomSearchBarView(placeholder: nil,
                                                    needBorderLine: true,
                                                    needCancelButton: true,
                                                    isDetailView: true)
    
    private let centerAlignmentButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .darkGray
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        return button
    }()
    
    private let accuracyAlignmentButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .darkGray
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        return button
    }()
    
    private lazy var buttonsView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 46))
        [centerAlignmentButton, accuracyAlignmentButton].forEach { view.addSubview($0) }
        centerAlignmentButton.anchor(left: view.leftAnchor, paddingLeft: 15)
        centerAlignmentButton.centerY(inView: view)
        
        accuracyAlignmentButton.anchor(left: centerAlignmentButton.rightAnchor, paddingLeft: 7)
        accuracyAlignmentButton.centerY(inView: view)
        return view
    }()
    
    private lazy var footerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.setupShadow(opacity: 0.3, radius: 1.5, offset: CGSize(width: 0, height: -2.0), color: .black)
        [placeNameLabel, placeCategoryLabel, reviewView, addressLabel, navigationButton, distanceLabel, buttonStackView].forEach { view.addSubview($0) }
        return view
    }()
    
    private let placeNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black.withAlphaComponent(0.8)
        label.font = UIFont.systemFont(ofSize: 17.5, weight: .medium)
        label.textAlignment = .left
        return label
    }()
    
    private let placeCategoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray.withAlphaComponent(0.8)
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .left
        return label
    }()
    
    private let reviewView = ReviewStarView()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .darkGray
        label.numberOfLines = 1
        return label
    }()
    
    private let navigationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "uTernIcon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = #colorLiteral(red: 0.03529411765, green: 0.5176470588, blue: 0.8901960784, alpha: 1)
        return label
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "save")?
            .withRenderingMode(.alwaysTemplate)
            .resizeImage(targetSize: CGSize(width: 25, height: 25)), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    private let phoneCallButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "phone")?
            .withRenderingMode(.alwaysTemplate)
            .resizeImage(targetSize: CGSize(width: 30, height: 30)), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let spaceLine = UIView()
        spaceLine.backgroundColor = .lightGray.withAlphaComponent(0.5)
        spaceLine.setDimensions(height: 38, width: 1)
       let sv = UIStackView(arrangedSubviews: [UIView(),
                                               phoneCallButton,
                                               spaceLine,
                                               saveButton,
                                               UIView()])
        sv.distribution = .equalSpacing
        sv.alignment = .center
        sv.layer.borderWidth = 1
        sv.layer.cornerRadius = 8
        sv.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        return sv
    }()
    
    // MARK: - Lifecycle

    override func loadView() {
        self.view = mapView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBarView.getSearchBar().text = viewModel.searchKeyword
        
        setAutolayout()
        checkIfTargetPlaceExists()
        
        LocationManager.shared.delegate = self
        
        bindAction()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        for item in mapView.poiItems {
            mapView.remove(item as? MTMapPOIItem)
        }
        
        for line in mapView.polylines {
            mapView.removePolyline(line as? MTMapPolyline)
        }
        // 화면에서 사라지면 mapView의 header와 footer 숨길 수 있는 제스처 없애기
//        mapView.removeGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(mapViewTapped)))
    }
    
    // MARK: - Bind
    
    /* action - 1. 길 안내 버튼 눌림 (하단바) - 길안내 표시
                2. 전화 버튼 눌림 (하단바) - 매장에 전화
                3. 즐겨찾기 버튼 탭 (하단바) - 즐겨찾기 추가
                4. x 버튼 - 메인으로 이동
                5. 화면 탭 - 상단,하단바 보이기/숨기기
                6. 검색 시작 - 검색 화면으로 이동
     */
    
    private func bindAction() {
        searchBarView.getMenuButton().addTarget(self,
                                                action: #selector(listButtonTapped),
                                                for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func listButtonTapped() {
        self.navigationController?.popViewController(animated: false)
    }
    
    // MARK: - Helpers
    
    private func setAutolayout() {
        view.addSubview(headerContainerView)
        headerContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 46 + 46 + 60)
        
        searchBarView.anchor(top: headerContainerView.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 60, paddingLeft: 15, paddingRight: 15, height: 46)
        
        buttonsView.anchor(top: searchBarView.bottomAnchor, left: headerContainerView.leftAnchor, right: headerContainerView.rightAnchor, paddingBottom: 10, height: 46)
        
        view.addSubview(footerContainerView)
        footerContainerView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, height: 190)
        
        placeNameLabel.anchor(top: footerContainerView.topAnchor, left: footerContainerView.leftAnchor, paddingTop: 16, paddingLeft: 16)
        placeCategoryLabel.anchor(left: placeNameLabel.rightAnchor, bottom: placeNameLabel.bottomAnchor, paddingLeft: 5)
        
        reviewView.anchor(top: placeNameLabel.bottomAnchor, left: placeNameLabel.leftAnchor, paddingTop: 5, width: 100)
        addressLabel.anchor(top: reviewView.bottomAnchor, left: placeNameLabel.leftAnchor, paddingTop: 7)
        
        navigationButton.anchor(top: footerContainerView.topAnchor, right: footerContainerView.rightAnchor, paddingTop: 12, paddingRight: 16, width: 50, height: 50)
        
        distanceLabel.anchor(top: navigationButton.bottomAnchor, paddingTop: 4)
        distanceLabel.centerX(inView: navigationButton)
        
        buttonStackView.anchor(top: distanceLabel.bottomAnchor, left: footerContainerView.leftAnchor, right: footerContainerView.rightAnchor, paddingTop: 15, paddingLeft: 20, paddingRight: 20)
    }
    
    
    /// mapView 세팅 - 선택된 장소 유무에 따라 맵뷰의 중심점 세팅하기
    private func setTargetMapView(with place: KeywordDocument?) {
        mapView.delegate = self
        mapView.currentLocationTrackingMode = .off
        
        makeMarker()
        
        guard let place = place,
              let stringLon = place.x,
              let stringLat = place.y,
              let lon = Double(stringLon),
              let lat = Double(stringLat),
              let placeId = place.id,
              let poiItems = mapView.poiItems as? [MTMapPOIItem]
        else {
            mapView.fitAreaToShowAllPOIItems()
            mapView.zoomOut(animated: true)
            return
        }
        mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: lat, longitude: lon)), zoomLevel: .min, animated: true)
        
        let targetPoi = poiItems.filter({ $0.tag == Int(placeId) })[0]
        mapView.select(targetPoi, animated: true)
    }
    
    /// 장소 선택 유무에 따라 다른 UI를 띄우기
    private func checkIfTargetPlaceExists() {
        configureUIwithDetailedData()
        guard let targetPlace = viewModel.targetPlace else {
            viewModel.targetPlace = viewModel.placeDatas[0]
            configureUIwithData(place: viewModel.targetPlace?.placeInfo)
            setTargetMapView(with: nil)
            return
        }
        configureUIwithData(place: targetPlace.placeInfo)
        setTargetMapView(with: targetPlace.placeInfo)
    }
    
    /// FooterView의 UI를 선택된 장소 유무에 따라 다르게 띄우기
    private func configureUIwithData(place: KeywordDocument?) {
        guard let place = place,
              let distance = place.distance else { return }
        placeNameLabel.text = place.placeName
        placeCategoryLabel.text = place.categoryGroupName
        addressLabel.text = place.roadAddressName
        distanceLabel.text = MeasureFormatter.measureDistance(distance: distance)
    }
    
    /// 선택된 장소에 대한 크롤링 데이터로 UI 세팅하기
    private func configureUIwithDetailedData() {
        guard let targetPlace = viewModel.targetPlace,
              let address = targetPlace.placeInfo.addressName,
              let data = viewModel.targetPlace?.placeDetail,
              let reviewCount = data.comment?.scorecnt,
              let totalScore = data.comment?.scoresum
                else {
            if let reviewStatus = viewModel.targetPlace?.placeDetail.comment?.reviewWriteBlocked {
                if reviewStatus != "NONE" {
                    print("후기 미제공 업체")
                    // 상세 주소가 있는 경우 상세주소 세팅
                    if let detailAddress = viewModel.targetPlace?.placeDetail.basicInfo?.address?.addrdetail {
                        self.addressLabel.text = (viewModel.targetPlace?.placeInfo.addressName!)! + " \(detailAddress)"
                    }
                    reviewView.configureBannedReviewUI()
                }
            }
            print("지도뷰 \(viewModel.targetPlace?.placeInfo.id)- 크롤링한 데이터 세팅 실패")
            return
        }
//         평균 별점
        let averageReviewPoint = (round((Double(totalScore) / Double(reviewCount)) * 10) / 10)
        // 상세 주소, 평균 별점, 썸네일 이미지 세팅
        DispatchQueue.main.async { [weak self] in
            self?.reviewView.configureUI(averagePoint: averageReviewPoint, reviewCount: reviewCount)
            if let detailAddress = data.basicInfo?.address?.addrdetail {
                self?.addressLabel.text = address + " \(detailAddress)"
            } else {
                print("상세 정보 세팅 x")
            }
        }
    }
    
    private func configureButtonUIforFavoritePlace(_ isFavoritePlace: Bool) {
        if !isFavoritePlace {
            self.saveButton.setImage(UIImage(named: "save")?
                .withRenderingMode(.alwaysTemplate)
                .resizeImage(targetSize: CGSize(width: 25, height: 25)), for: .normal)
            self.saveButton.tintColor = .gray
        } else {
            self.saveButton.setImage(UIImage(named: "save.filled")?
                .withRenderingMode(.alwaysTemplate)
                .resizeImage(targetSize: CGSize(width: 25, height: 25)), for: .normal)
            self.saveButton.tintColor = #colorLiteral(red: 0.9450980392, green: 0.768627451, blue: 0.05882352941, alpha: 1)
        }
    }
    
}

// MARK: - MTMapViewDelegate

extension ResultMapViewController: MTMapViewDelegate {
    
    func mapView(_ mapView: MTMapView!, selectedPOIItem poiItem: MTMapPOIItem!) -> Bool {
//        let targetPlace = viewModel.filterResults(with: poiItem.tag)
        print("선택된 위치 장소 코드 : \(poiItem.tag)")
        return false
    }
    
    // 메모리 차지가 많을 경우, 캐시 정리
    override func didReceiveMemoryWarning() {
        mapView.didReceiveMemoryWarning()
    }
    
    /// 검색 결과에 해당되는 장소에 마커 생성
    private func makeMarker() {
        
        for item in viewModel.placeDatas {
            guard let stringLon = item.placeInfo.x,
                  let stringLat = item.placeInfo.y,
                  let lat = Double(stringLat),
                  let lon = Double(stringLon),
                  let stringID = item.placeInfo.id,
                  let placeID = Int(stringID) else {
                print("마커 좌표값 옵셔널 벗기기 실패")
                return
            }
            self.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: lat, longitude: lon))

            let customPoiImage = UIImage(named: "bluePoint")?.resizeImage(targetSize: CGSize(width: 25, height: 25))
            let selectedPoiImage = UIImage(named: "selectedBluePoint")?.resizeImage(targetSize: CGSize(width: 35, height: 35))

            poiItem = MTMapPOIItem()
            poiItem?.markerType = .customImage
            poiItem?.customImage = customPoiImage

            poiItem?.markerSelectedType = .customImage
            poiItem?.customSelectedImage = selectedPoiImage

            poiItem?.mapPoint = mapPoint
            poiItem?.itemName = item.placeInfo.placeName
            poiItem?.tag = placeID
            mapView.add(poiItem)
        }
    }
    
    /// 장소 선택 - 네비게이션 버튼 클릭 후 실행됨 : 현재 위치로부터 선택된 장소까지의 경로 poly line 그리기
    private func makePolylines(guide: [Guide]) {
        // 선택된 장소를 제외한 poiItem 제거
        guard let poiItems = mapView.poiItems else { return }
        
        for item in poiItems {
            guard let item = item as? MTMapPOIItem,
                  let targetId = viewModel.targetPlace?.placeInfo.id else { return }
            if String(item.tag) != targetId {
                mapView.remove(item)
            }
        }

        var mapPoints: [MTMapPoint] = []
        
        polyLine = MTMapPolyline.polyLine()
        polyLine?.polylineColor = .blue
        
        for guide in guide {
            guard let lon = guide.x,
                  let lat = guide.y else {
                print("폴리라인 만드는 함수 - 옵셔널 벗기기 실패")
                return
            }
            
            mapPoints.append(MTMapPoint(geoCoord: MTMapPointGeo(latitude: lat,
                                                                longitude: lon)))
        }
        polyLine?.addPoints(mapPoints)
        
        DispatchQueue.main.async { [weak self] in
            self?.mapView.addPolyline(self?.polyLine)
            self?.mapView.fitArea(toShow: self?.polyLine)
        }
    }
    
}
