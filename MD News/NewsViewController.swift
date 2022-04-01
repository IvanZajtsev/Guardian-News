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
        static let image = UIImage(systemName: "network")!
        static let segueIdentidier = "toBodyScreen"
    }
    
    // MARK: - Private Properties
    
    @IBOutlet weak var tableView: UITableView!
    
    private var news = News(response: Response(results: [Article]()))
    
    private var images = [UIImage](repeating: C.image, count: 10)
    
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

    // MARK: - Private methods
    
    
    private func setupUI() {
        tabBarController?.tabBar.isHidden = false
        tableView.register(UINib(nibName: C.nibName, bundle: nil), forCellReuseIdentifier: C.reuseIdentifier)
        tableView.estimatedRowHeight = 560
        
        self.downloadJSON(q: C.defaultQ, completion: { [weak self] result in
            switch result {
            case .success(let moreData):
                self?.news = moreData
                self?.downloadImages()
                print("😳 loaded start pages")
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.isLoadingData = false
                }
            case .failure(_):
                break
            }
            
        })
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search ..."
        
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
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            
            guard let data = data,
                  error == nil else { return }
            do {
                let answer = try JSONDecoder().decode(News.self, from: data)
                
                //✅ про изображения тоже нужен completion
                completion(.success(answer))
            } catch {
                completion(.failure(error))
                print(error)
            }
            print("🙋🏼‍♀️")
            
        }).resume()
        
    }
    
    private func downloadImages() {
        for i in 0...((self.news.response?.results?.count ?? 1) - 1) {
            images = [UIImage](repeating: C.image, count: self.news.response?.results?.count ?? 1)
            self.downloadImage(index: i, completion: { [weak self] result in
                switch result {
                case .success(let image):
                    
                    self?.images[i] = image

                    
                case .failure(_):
                    break
                }
                
            })
        }
        
    }
    
    private func downloadImage(index: Int, completion: @escaping (Result<UIImage, Error>) -> ())  {
        
        guard let urlString = news.response?.results?[index]?.fields?.thumbnail,
              let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            
            guard let data = data,
                  error == nil else {
//                      completion(.failure())
                      return
                  }
            completion(.success(UIImage(data: data) ?? C.image))

        }).resume()
        
    }
    
    private func createURL(with q: String) -> String {
        print(C.leadingOfurl + q + C.trailingOfurl)
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
        
        self.performSegue(withIdentifier: C.segueIdentidier, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == C.segueIdentidier {
            guard let destinationVC = segue.destination as? ArticleViewController,
                  let selectedRow = tableView.indexPathForSelectedRow?.row else {return}
            
            destinationVC.body = news.response?.results?[selectedRow]?.fields?.body
            destinationVC.header = news.response?.results?[selectedRow]?.webTitle
            destinationVC.url = news.response?.results?[selectedRow]?.webUrl
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (tableView.contentSize.height - (100 + scrollView.frame.size.height)) {
            // fetch more data
            // продолжаем, если процесс НЕ запущен
            guard !isLoadingData else {
                // we are already fetching more data
                print("⚠️we are already fetching more data")
                return
            }
            self.tableView.tableFooterView = createSpinnerFooter()
            print("✅ loading")
            currentPage += 1
            downloadJSON(q: q, completion: { [weak self] result in
                DispatchQueue.main.async {
                    self?.tableView.tableFooterView = nil
                }
                switch result {
                case .success(let moreData):
                    self?.news.response!.results! += moreData.response!.results!
                    self?.downloadImages()
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                        self?.isLoadingData = false
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
        // вызови филтрацию
        
        guard let searchText = searchController.searchBar.text,
              !searchText.isEmpty,
              searchText.count > 2 else { return }
        q = searchText
        self.downloadJSON(q: q, completion: { [weak self] result in
            switch result {
            case .success(let moreData):
                self?.news = moreData
                self?.downloadImages()
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.isLoadingData = false
                }
            case .failure(_):
                break
            }
            
        })
        print("updateSearchResults called")
    }
    
    
}
