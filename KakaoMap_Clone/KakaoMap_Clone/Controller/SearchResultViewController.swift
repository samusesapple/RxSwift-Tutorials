//
//  SearchResultViewController.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/24.
//

import Foundation
import JGProgressHUD
import ReactorKit

final class SearchResultViewController: UIViewController, View {
    
    var reactor: SearchResultViewReactor!
    var disposeBag = DisposeBag()
    
    // MARK: - Components
    
    private let activity = UIActivityIndicatorView()

    private let progressHud = JGProgressHUD(style: .dark)

    private let searchBarView = CustomSearchBarView(placeholder: "장소 및 주소 검색",
                                                    needBorderLine: true,
                                                    needCancelButton: true)
    
    private let centerAlignmentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("지도중심 ▾", for: .normal)
        button.tintColor = .darkGray
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        return button
    }()
    
    private let accuracyAlignmentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("정확도순 ▾", for: .normal)
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
    
    private let borderLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .white 
        tv.rowHeight = view.frame.height / 7
        tv.register(SearchResultTableViewCell.self, forCellReuseIdentifier: "resultCell")
        return tv
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setAutolayout()
        setActions()
        searchBarView.getSearchBar().showsCancelButton = false
        
        bind(reactor: reactor)
    }
    
    // MARK: - Bind
    
    func bind(reactor: SearchResultViewReactor) {
        bindActions(reactor)
        bindStates(reactor)
    }
    
    private func bindActions(_ reactor: SearchResultViewReactor) {
        searchBarView.getSearchBar().searchTextField.rx.controlEvent(.allEditingEvents)
            .bind(onNext: { [weak self] _ in
                print("dismiss")
                self?.navigationController?.popViewController(animated: false)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .map({ SearchResultViewReactor.Action.didTappedCell($0.row) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindStates(_ reactor: SearchResultViewReactor) {
        // 키워드 세팅
        reactor.state
            .map({ $0.searchKeyword })
            .bind(to: searchBarView.getSearchBar().rx.text)
            .disposed(by: disposeBag)
        
        // 장소 검색 결과 데이터 셀에 뿌리기
        reactor.state
            .filter({ !$0.searchResults.isEmpty })
            .map({ $0.searchResults })
            .bind(to: tableView.rx.items(cellIdentifier: "resultCell",
                                         cellType: SearchResultTableViewCell.self)) { index, data, cell in
                cell.configureUIwithData(data: data.placeInfo)
                cell.setPlaceReviewData(data: data.placeDetail)
            }
            .disposed(by: disposeBag)
        
        // 셀 선택되면 선택된 셀에 대한 resultMapView 띄우기
        reactor.state
            .filter({ $0.selectedPlace != nil })
            .map({ ResultMapViewModel(userData: reactor,
                                      search: $0) })
            .map({ vm in
                let resultVC = ResultMapViewController()
                resultVC.viewModel = vm
                return resultVC
            })
            .bind(onNext: { self.navigationController?.pushViewController($0,
                                                                          animated: true)} )
            .disposed(by: disposeBag)
        
            
    }
    
    // MARK: - Actions
    
    @objc private func centerAlignmentButtonTapped() {
        // 정렬 옵션 선택할 view push 하기  >  정렬 옵션 변경 된 경우 버튼 글자 변경 및 테이블뷰 정렬 변경
        let firstButtonTapped = centerAlignmentButton.titleLabel?.text != "지도중심 ▾" ? true : false
        let alertVC = CustomAlignmentAlertViewController(isCenterAlignment: true,
                                                         firstButtonTapped: firstButtonTapped)
        alertVC.delegate = self
        alertVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        alertVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        present(alertVC, animated: true)
        print(#function)
    }
    
    @objc private func accuracyAlignmentButtonTapped() {
        // 정렬 옵션 선택할 view push 하기  >  정렬 옵션 변경 된 경우 버튼 글자 변경 및 테이블뷰 정렬 변경
        let firstButtonTapped = accuracyAlignmentButton.titleLabel?.text == "정확도순 ▾" ? true : false
        let alertVC = CustomAlignmentAlertViewController(isCenterAlignment: false,
                                                         firstButtonTapped: firstButtonTapped)
        alertVC.delegate = self
        alertVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        alertVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        present(alertVC, animated: true)
    }
    
    // MARK: - Helpers
    
    private func setAutolayout() {
        view.addSubview(searchBarView)
        searchBarView.setDimensions(height: 46, width: view.frame.width - 30)
        searchBarView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 10)
        searchBarView.centerX(inView: view)
        
        view.addSubview(buttonsView)
        buttonsView.setDimensions(height: 46, width: view.frame.width)
        buttonsView.anchor(top: searchBarView.bottomAnchor)
        
        view.addSubview(borderLineView)
        borderLineView.setDimensions(height: 1, width: view.frame.width)
        borderLineView.anchor(top: buttonsView.bottomAnchor)
        
        view.addSubview(tableView)
        tableView.anchor(top: borderLineView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        view.addSubview(activity)
        activity.anchor(bottom: view.bottomAnchor, paddingBottom: 30)
        activity.centerX(inView: view)
    }
    
    private func setActions() {
        centerAlignmentButton.addTarget(self, action: #selector(centerAlignmentButtonTapped), for: .touchUpInside)
        accuracyAlignmentButton.addTarget(self, action: #selector(accuracyAlignmentButtonTapped), for: .touchUpInside)
    }
}

// MARK: - CustomAlignmentAlertViewControllerDelegate

extension SearchResultViewController: CustomAlignmentAlertViewControllerDelegate {
    func getCurrentLocationBaseData() {
        print("현재 위치 기준으로 정보 받기")
        centerAlignmentButton.setTitle("내위치중심 ▾", for: .normal)
//        viewModel.isMapBasedData = false
//        viewModel.sortAccuracyAlignment()
    }
    
    func getMapBoundaryBaseData() {
        print("지도상 위치 기준으로 정보 받기")
        centerAlignmentButton.setTitle("지도중심 ▾", for: .normal)
//        viewModel.isMapBasedData = true
//        viewModel.sortAccuracyAlignment()
    }
    
    func correctInfoBaseAlignment() {
        print("정확도 순으로 정렬")
        accuracyAlignmentButton.setTitle("정확도순 ▾", for: .normal)
//        viewModel.isAccuracyAlignment = true
//        viewModel.sortAccuracyAlignment()
    }
    
    func shortDistanceFirstAlignment() {
        print("거리순으로 정렬")
        accuracyAlignmentButton.setTitle("거리순 ▾", for: .normal)
//        viewModel.isAccuracyAlignment = false
//        viewModel.sortAccuracyAlignment()
    }
}
