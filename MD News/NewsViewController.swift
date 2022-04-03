//
//  ViewController.swift
//  MD News
//
//  Created by Иван Зайцев on 29.03.2022.
//

import UIKit

class NewsViewController: UIViewController {
    
    //MARK: - Private Data Structures
    
    private enum C {
        static let reuseIdentifier = "ReusableCell"
        static let nibName = "HeaderCell"
        static let leadingOfurl = "https://content.guardianapis.com/search?"
        static let trailingOfurl = "api-key=908cb2e6-b6b3-4c92-87db-34afa38367d7&format=json&show-fields=thumbnail,trailText,body"
        static let defaultQ = "world"
        static let defaultURL = leadingOfurl + defaultQ + trailingOfurl
        static let image = UIColor(displayP3Red: 15 / 255, green: 15 / 255, blue: 15 / 255, alpha: 1).image()
        static let fromNewstoBodyScreen = "toBodyScreen"
    }
    enum Downloading {
        case anotherPage, firstPage
    }
    
    // MARK: - Private Properties
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
   
    @IBOutlet weak var tableView: UITableView!
    
    private var news = News(response: Response(results: [Article]()))
    
    private var images = [UIImage]()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var q = C.defaultQ
    
    private var isLoadingData = false
    
    private var currentPage = 1
    
    private var searchBarIsEmpty: Bool {
        
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
        
    }
    //     Example: https://content.guardianapis.com/search?page=2&q=debate&api-key=test
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupUI()
    
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Private methods
    
    private func setupUI() {
        
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        view.bringSubviewToFront(activityIndicator)
        searchController.searchBar.isUserInteractionEnabled = false
        
        tabBarController?.tabBar.isHidden = false
        tableView.register(UINib(nibName: C.nibName, bundle: nil), forCellReuseIdentifier: C.reuseIdentifier)
        tableView.estimatedRowHeight = 560
        
        self.downloadJSON(q: C.defaultQ, completion: { [weak self] result in
            switch result {
            case .success(let moreData):
                self?.news = moreData
                self?.downloadImages(from: .firstPage) {
                    print("😳 loaded start pages")
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                        self?.isLoadingData = false
                        self?.activityIndicator.isHidden = true
                        self?.searchController.searchBar.isUserInteractionEnabled = true
                    }
                }
            case .failure(_):
                
                //🟨 либо 404
                
                //🟨 либо ошибка декодирования
                
                break
            }
            
        })
        
        searchController.searchResultsUpdater = self
        
        searchController.searchBar.delegate = self
        searchController.searchBar.enablesReturnKeyAutomatically = true
        
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        tableView.dataSource = self
        tableView.delegate = self
        
        
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
        print("URL: " + "\(urlString)")
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            
            guard let data = data,
                  let statusCode = (response as? HTTPURLResponse)?.statusCode,
                  200...299 ~= statusCode,
                  error == nil else {
                      
                      // TODO: completion(.failure(error!))
                      // TODO: убрать форсе анвреп и мб сделать другие кейсы для ошибок? мб так что дата нил а ошибка не нил и ляжет приложение
                      
                      
                      print("🟦🅰️🟦🅰️🟦🅰️🟦🅰️🟦🅰️🟦🅰️🟦🅰️🟦🅰️🟦🅰️🟦🅰️🟦🅰️🟦🅰️" + "\(data)" + "\(response)" + "\(error)")
                      DispatchQueue.main.async {
                          self.searchController.searchBar.isUserInteractionEnabled = true
                          self.tableView.tableFooterView = nil
                          self.isLoadingData = false
                      }
                      

                    
                      return
                  }
            do {
                let answer = try JSONDecoder().decode(News.self, from: data)
                
                //✅ про изображения тоже нужен completion
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
            if let newCountOfArticles = self.news.response?.results?.count   {
                //                🅰️ здесь все таки надо работать не со всем списком саттьей, в котором есть и новые, а только с новыми
                // а то вдруг новые не могут скачаться и мы весь массив убьем....
                count = newCountOfArticles
            } else {
                //            count = 0
                count = images.count
            }
            let countOfNewImages = (self.news.response?.results?.count ?? images.count) - images.count
            //            print("countOfNewImages = " + "\(countOfNewImages)")
            //            print("self.news.response?.results?.count ?? images.count = " + "\(self.news.response?.results?.count ?? images.count)")
            //            print("images.count = " + "\(  images.count)")
            
            
            if countOfNewImages == 0 {
                return
            }
//            print(countOfNewImages)
            leftBound = count - countOfNewImages
            rightBound = count - 1
            images += [UIImage](repeating: C.image, count: countOfNewImages)
        case .firstPage:
            leftBound = 0
            guard let responseCount = self.news.response?.results?.count,
                  responseCount != 0 else { rightBound = 0; return }
            rightBound = responseCount - 1
            images += [UIImage](repeating: C.image, count: self.news.response?.results?.count ?? 0)
//            print(images.count)
//            print("❌")
        }
        /*
         // 🟨 короче если новых кратинок нет то надо отед=льно это обработать!
         // count - countOfNewImages ... count - 1
         */
        //        for i in count - countOfNewImages...(count - 1) {
        for i in leftBound...rightBound {
            group.enter()
            self.downloadImage(index: i) { [weak self] result in
                print("task № \(i)  ✅")
                
                switch result {
                    
                case .success(let image):
                    
                    self?.images[i] = image
                    
                case .failure(_):
                    break
                }
                group.leave()
            }
            //            }) print(#function + "⬜️  \(Thread.current.qualityOfService.rawValue)")
        }
        completion()
        group.notify(queue: .main) {
            print("All 📸  concurrent tasks completed")
            self.tableView.reloadData()
            
            
        }
    }
    
    private func downloadImage(index: Int, completion: @escaping (Result<UIImage, Error>) -> ())  {
        
        guard let urlString = news.response?.results?[index]?.fields?.thumbnail,
              let url = URL(string: urlString) else { return }
        //        print(#function + "😳  \(Thread.current.qualityOfService.rawValue)")
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            //            print(#function + "✅  \(Thread.current.qualityOfService.rawValue)")
            guard let data = data,
                  error == nil else {
                      // completion(.failure())
                      return
                  }
            completion(.success(UIImage(data: data) ?? C.image))
            
        }).resume()
        
    }
    
    private func createURL(with q: String) -> String {
        return C.leadingOfurl + "page=" + "\(currentPage)" + "&" + "q=" + q + "&" + C.trailingOfurl
    }
    
    
}

//MARK: - UITableViewDataSource

extension NewsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.response?.results?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: C.reuseIdentifier, for: indexPath) as? HeaderCell else {
            return UITableViewCell()
        }
        
        cell.headerLabel.text = news.response?.results?[indexPath.row]?.webTitle
        cell.trailingContextLabel.attributedText = news.response?.results?[indexPath.row]?.fields?.trailText?.convertHtmlToAttributedStringWithCSS(font: UIFont(name: "Arial", size: 20), csscolor: "white", lineheight: 9, csstextalign: "natural")
        cell.pictureImageView.image = (images.count == 0) ? C.image : images[indexPath.row]
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            
            self.performSegue(withIdentifier: C.fromNewstoBodyScreen, sender: self)
            self.tableView.deselectRow(at: indexPath, animated: true)
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == C.fromNewstoBodyScreen {
            guard let destinationVC = segue.destination as? ArticleViewController,
                  let selectedRow = tableView.indexPathForSelectedRow?.row else {return}
            destinationVC.body = news.response?.results?[selectedRow]?.fields?.body ?? "body)"
            destinationVC.header = news.response?.results?[selectedRow]?.webTitle ?? "header)"
            destinationVC.url = news.response?.results?[selectedRow]?.webUrl ?? "url)"
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let position = scrollView.contentOffset.y
        if position > (tableView.contentSize.height - (100 + scrollView.frame.size.height)) {
            // fetch more data
            // продолжаем, если процесс НЕ запущен
            guard !isLoadingData else {
                // we are already fetching more data
//                print("⚠️we are already fetching more data")
                return
            }
            self.tableView.tableFooterView = createSpinnerFooter()
            searchController.searchBar.isUserInteractionEnabled = false
            print("✅ loading")
            currentPage += 1
            downloadJSON(q: q, completion: { [weak self] result in
                
                switch result {
                case .success(let moreData):
//                    print(moreData.response!)
                    self?.news.response!.results! += moreData.response!.results!
                    self?.downloadImages(from: .anotherPage) {
                        
                        DispatchQueue.main.async {
                            self?.tableView.tableFooterView = nil
                            self?.searchController.searchBar.isUserInteractionEnabled = true
                            self?.tableView.reloadData()
                            self?.isLoadingData = false
                        }
                    }
                    
                case .failure(_):
                    break
                }
                
            })
        }
    }
}

// MARK: - UISearchResultsUpdating

extension NewsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        
    }
    
}
extension NewsViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        print("💖")
        searchBar.placeholder = "At least 3 symbols"
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.placeholder = "Search"
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        print("🟨")
        guard let searchText = searchController.searchBar.text,
              !searchText.isEmpty,
              searchText.count > 2 else {
                  return
                  
              }
        q = searchText
        currentPage = 1
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        view.bringSubviewToFront(activityIndicator)
        
        self.downloadJSON(q: q, completion: { [weak self] result in
            switch result {
            case .success(let moreData):
                self?.news = moreData
                self?.images.removeAll()
                self?.downloadImages(from: .firstPage) {
                    DispatchQueue.main.async {
                        self?.activityIndicator.isHidden = true
                        self?.tableView.reloadData()
                        self?.isLoadingData = false
                    }
                }
                
            case .failure(_):
                break
            }
        })
        
    }
    
}

extension UIColor {
    func image(_ size: CGSize = CGSize(width: 5, height: 3)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
    
}
