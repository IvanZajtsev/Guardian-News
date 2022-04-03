//
//  FavoritesViewController.swift
//  MD News
//
//  Created by Иван Зайцев on 02.04.2022.
//

import Foundation
import UIKit

class FavoritesViewController: UIViewController {
    
    enum C {
        static let reusableCell = "anotherReusableCell"
        static let segueIdentifier = "fromFavToBody"
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var arcticles: [ArticleData] = []
    
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
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
    
    private func loadArticlesFromPList() {
        arcticles = DataFileManager().loadArticleData()
    }
}

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
