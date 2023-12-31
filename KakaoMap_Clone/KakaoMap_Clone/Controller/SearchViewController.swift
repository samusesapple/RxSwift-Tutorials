//
//  SearchViewController.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/23.
//

import JGProgressHUD
import ReactorKit
import Toast_Swift
import UIKit

final class SearchViewController: UIViewController, View {

    var reactor: SearchViewModel!
    
    var disposeBag = DisposeBag()
    
    // MARK: - Components
    
    private let progressHud = JGProgressHUD(style: .dark)
    
    private let searchBarView = CustomSearchBarView(placeholder: "장소 및 주소 검색",
                                                    needBorderLine: true)
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isPagingEnabled = false
        cv.showsHorizontalScrollIndicator = false
        cv.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        cv.register(MenuCollectionViewCell.self, forCellWithReuseIdentifier: "menuCell")
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    private let borderLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let header = UIView()
        header.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
        
        let currentLabel = UILabel()
        currentLabel.text = "최근 검색"
        currentLabel.textColor = .black
        currentLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        header.addSubview(currentLabel)
        currentLabel.centerY(inView: header)
        currentLabel.anchor(left: header.leftAnchor, paddingLeft: 20)
        
        let tv = UITableView()
        tv.tableHeaderView = header
        tv.backgroundColor = .white
        tv.rowHeight = view.frame.height / 15
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setAutolayout()
        setActions()
        
        searchBarView.getSearchBar().delegate = self
        bind(reactor: reactor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchBarView.getSearchBar().searchTextField.becomeFirstResponder()
    }
    
    // MARK: - Bind

    func bind(reactor: SearchViewModel) {
        bindAction(reactor)
        bindState(reactor)
    }
    
    private func bindAction(_ reactor: SearchViewModel) {
        searchBarView.getSearchBar().searchTextField.rx.controlEvent(.editingDidEnd)
            .map({ [weak self] in
                let keyword = self?.searchBarView.getSearchBar().searchTextField.text
                return SearchViewModel.Action.startedSearching(keyword!)
            })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: SearchViewModel) {
        
        let finalObservable = Observable.combineLatest(reactor.state,
                                 reactor.resultDataPublisher) { state, results in
            return SearchViewModel.State(searchKeyword: state.searchKeyword,
                                  searchResults: results)
        }
            
        finalObservable
            .filter({ !$0.searchResults.isEmpty })
            .map({ SearchResultViewReactor(reactor, search: $0) })
            .bind(onNext: { reactor in
                let resultVC = SearchResultViewController()
                resultVC.reactor = reactor
                print(reactor.state)
                self.navigationController?.pushViewController(resultVC,
                                                              animated: false)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: false)
    }
    
    // MARK: - Helpers
    
    private func setAutolayout() {
        view.addSubview(searchBarView)
        searchBarView.setDimensions(height: 46, width: view.frame.width - 30)
        searchBarView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 10)
        searchBarView.centerX(inView: view)
        
        view.addSubview(collectionView)
        collectionView.setDimensions(height: 46, width: view.frame.width)
        collectionView.anchor(top: searchBarView.bottomAnchor)
        
        view.addSubview(borderLineView)
        borderLineView.setDimensions(height: 1, width: view.frame.width)
        borderLineView.anchor(top: collectionView.bottomAnchor)
        
        view.addSubview(tableView)
        tableView.anchor(top: borderLineView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    }
    
    private func setActions() {
        searchBarView.getMenuButton().addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource & UICollectionViewDelegateFlowLayout

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reactor.searchOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "menuCell", for: indexPath) as! MenuCollectionViewCell
        cell.configureUI(with: reactor.searchOptions[indexPath.row])
        cell.contentView.backgroundColor = .clear
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 지도 위치 근처에 있는 선택된 카테고리의 장소 보여줘야함
        searchBarView.getSearchBar().searchTextField.text = reactor.searchOptions[indexPath.row].title
        searchBarView.getSearchBar().resignFirstResponder()

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = reactor.getCellWidth(with: reactor.searchOptions[indexPath.row])
        return CGSize(width: cellWidth, height: 45)
    }
    
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reactor.searchHistories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .clear
        cell.textLabel?.text = reactor.searchHistories[indexPath.row].searchText
        cell.imageView?.image = reactor.searchHistories[indexPath.row].type
        
        let backgroundColorView = UIView()
        backgroundColorView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        cell.selectedBackgroundView = backgroundColorView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let cell = tableView.cellForRow(at: indexPath),
        let keyword = cell.textLabel?.text,
        let image = cell.imageView?.image else { return }
        // 1. 장소 정보 없는 검색의 경우 - 현재 위치 기준으로 해당 키워드로 검색 -> SearchResultVC에 결과 띄우기
//        if image == UIImage(systemName: "magnifyingglass") {
//            viewModel.getKeywordSearchResult(with: keyword)
//        }
//        // 2. 장소 정보 있는 경우 - 장소의 상세 페이지 보여주기
//        if image == UIImage(systemName: "building.2") {
//            viewModel.getTargetPlace(with: keyword)
//        }
    }
    
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //        print("검색중")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        searchBar.resignFirstResponder()
        if text != " " {
//            viewModel.getKeywordSearchResult(with: text)
        }
    }
}
