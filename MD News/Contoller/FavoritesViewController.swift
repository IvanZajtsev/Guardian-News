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
    }
    
    var arcticles: [ArticleData] = []
    
    // MARK: - UI
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .large
        activityIndicator.backgroundColor = .black
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        return activityIndicator
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: C.reusableCell)
        tableView.dataSource = self
        tableView.delegate = self
        
        return tableView
    }()
    
    // MARK: - Lifecycle
    
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
    
    // MARK: - Private Methods
    
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
            
            let nextVC = ArticleViewController()
            nextVC.body = self.arcticles[indexPath.row].bodyText
            nextVC.header = self.arcticles[indexPath.row].labelText
            nextVC.url = self.arcticles[indexPath.row].url
            nextVC.isFavScreenOpened = true
            
            self.navigationController?.pushViewController(nextVC, animated: false)
            
            self.tableView.deselectRow(at: indexPath, animated: true)
            
        }
        
    }
    
}
