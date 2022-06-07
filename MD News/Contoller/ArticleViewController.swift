//
//  ArticleViewController.swift
//  MD News
//
//  Created by Иван Зайцев on 29.03.2022.
//

import Foundation
import UIKit

class ArticleViewController: UIViewController {
    
    private enum Constants {
        static let inset: CGFloat = 10
    }
    
    var body: String = "Loading..."
    var header: String = "Loading..."
    var url: String = "URL"
    
    var modifiedBody = ""
    var attributedString =  NSAttributedString()
    
    var isFavScreenOpened = false
    
    static var picWidth = 0
    static var picHeight = 0
    
    // MARK: - ScrollView components
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    
    private lazy var infoView: UIView = {
        let infoView = UIView()
        infoView.translatesAutoresizingMaskIntoConstraints = false
        
        return infoView
        
    }()
    
    // MARK: - Content of ScrollView
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.textAlignment = .natural
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        
        return textView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .medium
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        return activityIndicator
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .natural
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.numberOfLines = 0
        
        return label
    }()
    
    // MARK: - Bar Button Items
    
    private lazy var goToSourceButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "network"), style: .plain, target: self, action: #selector(goToSourceTapped))
        
        return button
    }()
    
    private lazy var favoritesButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "star"), style: .plain, target: self, action: #selector(addToFavoritesTapped))
        
        return button
    }()
    
    private lazy var shareButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonPressed))
        
        return button
    }()
    
    // MARK: - Actions
    
    @objc private func shareButtonPressed() {
        
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
        present(vc, animated: true)
    }
    
    @objc private func addToFavoritesTapped() {
        addToFavorites()
    }
    
    @objc private func goToSourceTapped() {
        
        guard let urlToOpen = URL(string: url) else { return }
        
        if UIApplication.shared.canOpenURL(urlToOpen) {
            UIApplication.shared.open(urlToOpen, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    override func viewDidLayoutSubviews() {
        // TODO: сделать констраинтами это
        scrollView.frame = self.view.bounds
        
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(infoView)
        
        infoView.addSubview(activityIndicator)
        infoView.addSubview(label)
        infoView.addSubview(textView)
        
        
        
        // на скролл вью нет костраинтов потому что  ]сразу фрейм ему прописал чтобы не мучатьтся
        let constraints = [
            infoView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            infoView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            infoView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            infoView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            infoView.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            activityIndicator.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: Constants.inset),
            activityIndicator.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -Constants.inset),
            activityIndicator.topAnchor.constraint(equalTo: infoView.topAnchor, constant: Constants.inset),
            activityIndicator.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -Constants.inset),
            
            label.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: Constants.inset),
            label.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -Constants.inset),
            //            label.topAnchor.constraint(equalTo: activityIndicator.topAnchor),
            label.bottomAnchor.constraint(equalTo: textView.topAnchor, constant: -Constants.inset),
            
            textView.leadingAnchor.constraint(equalTo: infoView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: infoView.trailingAnchor),
            //            label.topAnchor.constraint(equalTo: activityIndicator.topAnchor),
            textView.bottomAnchor.constraint(equalTo: infoView.bottomAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        navigationItem.rightBarButtonItems = [goToSourceButton, favoritesButton, shareButton]
        
        label.text = header
        
        label.isHidden = true
        textView.isHidden = true
        
        goToSourceButton.isEnabled = false
        favoritesButton.isEnabled = false
        shareButton.isEnabled = false
        
        activityIndicator.startAnimating()
        
        tabBarController?.tabBar.isHidden = true
        
        ArticleViewController.picWidth = Int(round(textView.frame.size.width * 0.87))
        ArticleViewController.picHeight = Int(round(textView.frame.size.width * 0.87 * 0.6))
        
        modifiedBody = body.createModifiedHTMLString(font: UIFont(name: "PingFang HK", size: 20), csscolor: "white", lineheight: 12, csstextalign: "natural")
        
        DispatchQueue.main.async {
            
            self.attributedString = self.body.convertHtmlToAttributedStringWithCSS(font: UIFont(name: "PingFang HK", size: 20), csscolor: "white", lineheight: 12, csstextalign: "natural") ?? NSAttributedString()
            self.textView.attributedText = self.attributedString
            self.activityIndicator.isHidden = true
            self.label.isHidden = false
            self.textView.isHidden = false
            self.goToSourceButton.isEnabled = true
            if !self.isFavScreenOpened { self.favoritesButton.isEnabled = true }
            self.shareButton.isEnabled = true
        }
    }
    
    private func addToFavorites() {
        
        let manager = DataFileManager()
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        
        DispatchQueue.main.async {
            do {
                try manager.saveArticleData(ArticleData(labelText: self.header, bodyText: self.modifiedBody, url: self.url))
                self.activityIndicator.isHidden = true
                let alert = UIAlertController(title: "Saved to favorites", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                
            } catch {
                print(error)
            }
        }
    }
}

// MARK: - Extensions

extension String {
    public var convertHtmlToNSAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8, allowLossyConversion: true) else {
            return nil
        }
        do {
            return try NSAttributedString(data: data,options: [.documentType: NSAttributedString.DocumentType.html,.characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
    }
    public func createModifiedHTMLString(font: UIFont? , csscolor: String , lineheight: Int, csstextalign: String) -> String {
        let safeFont = font ?? UIFont(name: "PingFang HK", size: 20)!
        return "<style> img { width: \(ArticleViewController.picWidth)px; height: \(ArticleViewController.picHeight)px; } body{font-family: '\(safeFont.fontName)'; font-size:\(safeFont.pointSize)px; color: \(csscolor); line-height: \(lineheight)px; text-align: \(csstextalign); }</style>\(self)"
    }
    public func convertHtmlToAttributedStringWithCSS(font: UIFont? , csscolor: String , lineheight: Int, csstextalign: String) -> NSAttributedString? {
        guard let font = font else {
            return convertHtmlToNSAttributedString
        }
        let modifiedString = "<style> img { width: \(ArticleViewController.picWidth)px; height: \(ArticleViewController.picHeight)px; } body{font-family: '\(font.fontName)'; font-size:\(font.pointSize)px; color: \(csscolor); line-height: \(lineheight)px; text-align: \(csstextalign); }</style>\(self)";
        guard let data = modifiedString.data(using: .utf8, allowLossyConversion: true) else {
            return nil
        }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        }
        catch {
            print(error)
            return nil
        }
    }
}

