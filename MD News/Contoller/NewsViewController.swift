//
//  ViewController.swift
//  MD News
//
//  Created by Иван Зайцев on 29.03.2022.
//

import UIKit
import Network

enum PossibleErrors: Error {
  case httpError
}

class NewsViewController: UIViewController {
    
    
    //MARK: - Private Data Structures
    
    private enum C {
        static let reuseIdentifier = "reusableCell"
        static let nibName = "HeaderCell"
        static let leadingOfurl = "https://content.guardianapis.com/search?"
        static let trailingOfurl = "api-key=908cb2e6-b6b3-4c92-87db-34afa38367d7&format=json&show-fields=thumbnail,trailText,body"
        static let defaultQ = "world"
        static let defaultURL = leadingOfurl + defaultQ + trailingOfurl
        static let image = UIColor(displayP3Red: 15 / 255, green: 15 / 255, blue: 15 / 255, alpha: 1).image()
        static let fromNewstoBodyScreen = "toBodyScreen"
        static let estimatedRowHeight: CGFloat = 470
    }
    enum Downloading {
        case anotherPage, firstPage
    }
    
    // MARK: - Private Properties
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
   
//    @IBOutlet weak var tableView: UITableView!
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(HeaderCell.self, forCellReuseIdentifier: HeaderCell.identifier)
        tableView.estimatedRowHeight = C.estimatedRowHeight
        tableView.dataSource = self
        tableView.delegate = self
        
        return tableView
    }()
    
    private var news = News(response: Response(results: [Article]()))
    
    private var images = [UIImage]()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var q = C.defaultQ
    
    private var isLoadingData = false
    
    private var currentPage = 1
        
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupUI()
        monitorNetwork()
    
    }
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        searchController.searchBar.isUserInteractionEnabled = true
        
    }

    // MARK: - Private methods
    
    private func setupUI() {
        
        tabBarController?.tabBar.isHidden = false
//        tableView.register(UINib(nibName: C.nibName, bundle: nil), forCellReuseIdentifier: C.reuseIdentifier)
//        tableView.estimatedRowHeight = C.estimatedRowHeight
//        tableView.dataSource = self
//        tableView.delegate = self
        view.addSubview(tableView)
        
        let constraints = [
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.enablesReturnKeyAutomatically = true
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search"
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        
        downloadFirstPage()
        
    }
    
    private func downloadFirstPage() {
        
        currentPage = 1
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        view.bringSubviewToFront(activityIndicator)
        
        searchController.searchBar.isUserInteractionEnabled = false
        
        
        self.downloadJSON(q: q, completion: { [weak self] result in
            switch result {
            case .success(let moreData):
                self?.news = moreData
                self?.images.removeAll()
                self?.downloadImages(from: .firstPage) {
                    DispatchQueue.main.async {
                        self?.searchController.searchBar.isUserInteractionEnabled = true
                        self?.activityIndicator.isHidden = true
                        self?.tableView.reloadData()
                        self?.isLoadingData = false
                    }
                }
                
            case .failure(let error):
                if error is PossibleErrors {
                    DispatchQueue.main.async {
                        self?.showSimpleOKAlert(with: "Error with HTTP request", and: "Search through text field")
                        self?.searchController.searchBar.isUserInteractionEnabled = true
                        self?.tableView.tableFooterView = nil
                        self?.isLoadingData = false
                        self?.activityIndicator.isHidden = true
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.showSimpleOKAlert(with: "Error decoding JSON", and: "Search through text field")
                        self?.searchController.searchBar.isUserInteractionEnabled = true
                        self?.tableView.tableFooterView = nil
                        self?.isLoadingData = false
                        self?.activityIndicator.isHidden = true
                    }
                }
            }
        })
    }
    
    private func downloadAnotherPage() {
        
        self.tableView.tableFooterView = createSpinnerFooter()
        searchController.searchBar.isUserInteractionEnabled = false
        
        currentPage += 1
        
        downloadJSON(q: q, completion: { [weak self] result in
            
            switch result {
            case .success(let moreData):
                self?.news.response!.results! += moreData.response!.results!
                self?.downloadImages(from: .anotherPage) {
                    
                    DispatchQueue.main.async {
                        self?.tableView.tableFooterView = nil
                        self?.searchController.searchBar.isUserInteractionEnabled = true
                        self?.tableView.reloadData()
                        self?.isLoadingData = false
                    }
                }
                
            case .failure(let error):
                if error is PossibleErrors {
                    
                    self?.currentPage -= 1
                    
                    DispatchQueue.main.async {
                        self?.showSimpleOKAlert(with: "Error with HTTP request", and: "Search through text field")
                        self?.searchController.searchBar.isUserInteractionEnabled = true
                        self?.tableView.tableFooterView = nil
                        self?.isLoadingData = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.showSimpleOKAlert(with: "Error decoding JSON", and: "Search through text field")
                        self?.searchController.searchBar.isUserInteractionEnabled = true
                        self?.tableView.tableFooterView = nil
                        self?.isLoadingData = false
                        
                    }
                    
                }
            }
            
        })
    }
    
    private func showSimpleOKAlert(with alertTitle: String, and alertMessage: String) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true) 
        
    }
    
    private func monitorNetwork() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
            } else {
                DispatchQueue.main.async {
                    
                    self.showSimpleOKAlert(with: "No connection", and: "Ensure you have connection")
                }
            }
        }
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
    }
    
    private func createSpinnerFooter() -> UIView{
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        
        return footerView
    }
    
    private func downloadJSON(q: String, completion: @escaping (Result<News, Error>) -> ()) {
        
        isLoadingData = true
        
        let urlString = createURL(with: q)
        
        guard let url = URL(string: urlString) else { completion(.failure(PossibleErrors.httpError)); return }
        
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            
            guard let data = data,
                  let statusCode = (response as? HTTPURLResponse)?.statusCode,
                  200...299 ~= statusCode,
                  error == nil else {
                      completion(.failure(PossibleErrors.httpError))
                      
                      return
                  }
            do {
                let answer = try JSONDecoder().decode(News.self, from: data)
                completion(.success(answer))
                
            } catch {
                
                completion(.failure(error))
                print(error)
            }
            
            
        }).resume()
        
    }
    
    private func downloadImages(from: Downloading, completion: @escaping () -> ()) {
        
        let group = DispatchGroup()
        
        var count = 0
        var leftBound = 0
        var rightBound = 0
        
        switch from {
            
        case .anotherPage:
            
            if let newCountOfArticles = self.news.response?.results?.count {
                count = newCountOfArticles
            } else {
                count = images.count
            }
            let countOfNewImages = (self.news.response?.results?.count ?? images.count) - images.count
            
            if countOfNewImages == 0 {
                completion()
                return
            }
            
            leftBound = count - countOfNewImages
            rightBound = count - 1
            
            images += [UIImage](repeating: C.image, count: countOfNewImages)
            
        case .firstPage:
            
            leftBound = 0
            
            if let responseCount = self.news.response?.results?.count, responseCount != 0 {
                rightBound = responseCount - 1
            } else {
                rightBound = 0
            }
            
            images += [UIImage](repeating: C.image, count: self.news.response?.results?.count ?? 0)
        }

        if rightBound != 0 {
            for i in leftBound...rightBound {
                group.enter()
                self.downloadImage(index: i) { [weak self] result in
                    
                    switch result {
                        
                    case .success(let image):
                        
                        self?.images[i] = image
                        
                    case .failure(_):
                        
                        break
                    }
                    group.leave()
                }
               
            }
        }
        completion()
        if rightBound == 0 {
            DispatchQueue.main.async {
                self.showSimpleOKAlert(with: "No results", and: "Search through text field")
            }
        }
        group.notify(queue: .main) {
            self.tableView.reloadData()
        }
        
    }
    
    private func downloadImage(index: Int, completion: @escaping (Result<UIImage, Error>) -> ())  {
        
        guard let results = news.response?.results,
              !results.isEmpty,
              let urlString = news.response?.results?[index]?.fields?.thumbnail,
              let url = URL(string: urlString) else {
                  completion(.success(C.image))
                  return
              }
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            
            guard let data = data,
                  error == nil else {
                      completion(.success(C.image))
                      return
                  }
            completion(.success(UIImage(data: data) ?? C.image))
            
        }).resume()
        
    }
    
    private func createURL(with q: String) -> String {
        return C.leadingOfurl + "page=" + "\(currentPage)" + "&" + "q=" + q + "&" + C.trailingOfurl
    }
    
    
}

//MARK: - UITableViewDataSource, UITableViewDelegate

extension NewsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.response?.results?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: C.reuseIdentifier, for: indexPath) as? HeaderCell else {
            return UITableViewCell()
        }
        
        cell.headerLabel.text = news.response?.results?[indexPath.row]?.webTitle
        cell.trailingContextLabel.attributedText = news.response?.results?[indexPath.row]?.fields?.trailText?.convertHtmlToAttributedStringWithCSS(font: UIFont(name: "Sinhala Sangam MN", size: 20), csscolor: "white", lineheight: 9, csstextalign: "natural")
        cell.pictureImageView.image = (images.count == 0) ? C.image : images[indexPath.row]
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            
            self.performSegue(withIdentifier: C.fromNewstoBodyScreen, sender: self)
            self.tableView.deselectRow(at: indexPath, animated: true)
            
        }
        
    }
    // TODO: надо посчитать размер ячейки а не угадывать
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 526
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == C.fromNewstoBodyScreen {
            guard let destinationVC = segue.destination as? ArticleViewController,
                  let selectedRow = tableView.indexPathForSelectedRow?.row else {return}
            destinationVC.body = news.response?.results?[selectedRow]?.fields?.body ?? "body"
            destinationVC.header = news.response?.results?[selectedRow]?.webTitle ?? "header"
            destinationVC.url = news.response?.results?[selectedRow]?.webUrl ?? "url"
            
        }
    }
    
    // MARK: - ScrollView method
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let position = scrollView.contentOffset.y
        let tabBarHeight = tabBarController?.tabBar.frame.size.height ?? 0
        
        if position + scrollView.frame.size.height -  tabBarHeight > tableView.contentSize.height + 40 {
            
            guard !isLoadingData else { return }
            
            guard (news.response?.pages ?? currentPage ) != currentPage && (news.response?.pages ?? -1 ) != 0 else {
                
                DispatchQueue.main.async {
                    self.showSimpleOKAlert(with: "No more articles", and: "Search through text field")
                    self.searchController.searchBar.isUserInteractionEnabled = true
                    self.tableView.tableFooterView = nil
                    self.isLoadingData = false
                }
                return
            }
            
            downloadAnotherPage()
        
        }
    }
}

// MARK: - UISearchResultsUpdating

extension NewsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
}

// MARK: - UISearchBarDelegate

extension NewsViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.placeholder = "At least 3 symbols"
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.placeholder = "Search"
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let searchText = searchController.searchBar.text,
              !searchText.isEmpty,
              searchText.count > 2 else { return }
        
        q = searchText.filter {!$0.isWhitespace}
        
        downloadFirstPage()
        
    }
    
}
    // MARK: - UIColor Extension

extension UIColor {
    func image(_ size: CGSize = CGSize(width: 5, height: 3)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
    
}
