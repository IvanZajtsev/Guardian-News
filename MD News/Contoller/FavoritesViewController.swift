//
//  FavoritesViewController.swift
//  MD News
//
//  Created by Иван Зайцев on 02.04.2022.
//

import Foundation
import UIKit
import Network

class FavoritesViewController: UIViewController {
    
    enum C {
        static let reusableCell = "anotherReusableCell"
        static let segueIdentifier = "fromFavToBody"
    }
    
    //    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //    @IBOutlet weak var tableView: UITableView!
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .large
        activityIndicator.backgroundColor = .black
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        return activityIndicator
    }()
    
    //    @IBOutlet weak var tableView: UITableView!
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: C.reusableCell)
        tableView.dataSource = self
        tableView.delegate = self
        
        return tableView
    }()
    
    var arcticles: [ArticleData] = []
    
    override func viewDidLoad() {
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        view.bringSubviewToFront(activityIndicator)
        
        loadArticlesFromPList()
        tabBarController?.tabBar.isHidden = false
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = true
            self.tableView.reloadData()
        }
        
    }
    
    private func setupUI() {
        
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        
        let constraints = [
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            activityIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            activityIndicator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        view.bringSubviewToFront(activityIndicator)
    }
    
    private func loadArticlesFromPList() {
        arcticles = DataFileManager().loadArticleData()
    }
}

// MARK: - UITableViewDataSource

extension FavoritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: C.reusableCell, for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = arcticles[indexPath.row].labelText
        return cell
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arcticles.count
    }
    
}

    // MARK: - UITableViewDelegate

extension FavoritesViewController: UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            
            self.performSegue(withIdentifier: C.segueIdentifier, sender: self)
            self.tableView.deselectRow(at: indexPath, animated: true)
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == C.segueIdentifier {
            guard let destinationVC = segue.destination as? ArticleViewController,
                  let selectedRow = tableView.indexPathForSelectedRow?.row else {return}
            destinationVC.body = arcticles[selectedRow].bodyText
            destinationVC.header = arcticles[selectedRow].labelText
            destinationVC.url = arcticles[selectedRow].url
            destinationVC.isFavScreenOpened = true
            
        }
    }
}
