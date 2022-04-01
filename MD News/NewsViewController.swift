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
        static let leadingOfurl = "https://content.guardianapis.com/search?q="
        static let trailingOfurl = "&api-key=908cb2e6-b6b3-4c92-87db-34afa38367d7&format=json&show-fields=thumbnail,trailText,body"
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
    
    private var searchBarIsEmpty: Bool {
        
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
        
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupUI()
        
    }

    // MARK: - Private methods
    
    private func setupUI() {
        tableView.register(UINib(nibName: C.nibName, bundle: nil), forCellReuseIdentifier: C.reuseIdentifier)

        
        self.JSON(q: C.defaultQ) {
            self.downloadImages()
        }
            
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search ..."
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
        tableView.dataSource = self
        tableView.delegate = self
        
        
    }
    
    private func JSON(q: String, completion: @escaping () -> ()) {
        let urlString = createURL(with: q)
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            
            guard let data = data,
                  error == nil else { return }
            do {
                let answer = try JSONDecoder().decode(News.self, from: data)
                self.news = answer
                completion()
            } catch {
                print(error)
            }
        }).resume()
        
    }
    
    private func downloadImages() {
        for i in 0...((self.news.response?.results?.count ?? 1) - 1) {
            self.dowloadImage(index: i, completion: {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        }
        
    }
    
    private func dowloadImage(index: Int, completion: @escaping () -> ())  {
        
        guard let urlString = news.response?.results?[index]?.fields?.thumbnail,
              let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            
            guard let data = data,
                  error == nil else { return }
            
            self.images[index] = UIImage(data: data) ?? C.image
            completion()
        }).resume()
        
    }
    
    private func createURL(with q: String) -> String {
        return C.leadingOfurl + q + C.trailingOfurl
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
        cell.trailingContextLabel.text = news.response?.results?[indexPath.row]?.fields?.trailText
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
            destinationVC.title = news.response?.results?[selectedRow]?.webTitle
            destinationVC.body = news.response?.results?[selectedRow]?.fields?.body
            destinationVC.header = news.response?.results?[selectedRow]?.webTitle
            destinationVC.url = news.response?.results?[selectedRow]?.webUrl
//            print(news.response?.results?[selectedRow]?.webUrl)
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
        self.JSON(q: searchText, completion: {
            self.downloadImages()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        print("updateSearchResults called")
    }
    
    
}
