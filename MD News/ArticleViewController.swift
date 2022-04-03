//
//  ArticleViewController.swift
//  MD News
//
//  Created by Иван Зайцев on 29.03.2022.
//

import Foundation
import UIKit

class ArticleViewController: UIViewController {
    
    
    var body: String = "Loading..."
    var header: String = "Loading..."
    var url: String = "URL"
    
    var modifiedBody = ""
    var attributedString =  NSAttributedString()
    
    var isFavScreenOpened = false
    
    static var picWidth = 0
    static var picHeight = 0
    
    // MARK: - Outlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var goToSourceButton: UIBarButtonItem!
    @IBOutlet weak var favoritesButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    // MARK: - Actions
    
    @IBAction func addToFavoritesTapped(_ sender: UIBarButtonItem) {
        addToFavorites()
    }
    
    @IBAction func goToSourceTapped(_ sender: UIBarButtonItem) {
        
        guard let urlToOpen = URL(string: url) else { return }
        
        if UIApplication.shared.canOpenURL(urlToOpen) {
             UIApplication.shared.open(urlToOpen, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: - Lifcycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        label.isHidden = true
        textView.isHidden = true
        goToSourceButton.isEnabled = false
        favoritesButton.isEnabled = false
        shareButton.isEnabled = false
        activityIndicator.startAnimating()
        
        tabBarController?.tabBar.isHidden = true
        label.text = header
        
        ArticleViewController.picWidth = Int(round(textView.frame.size.width * 0.87))
        ArticleViewController.picHeight = Int(round(textView.frame.size.width * 0.87 * 0.6))
        print("🅰️до установки аттрибутированного текста")
        modifiedBody = body.createModifiedHTMLString(font: UIFont(name: "Arial", size: 20), csscolor: "white", lineheight: 9, csstextalign: "natural")
        DispatchQueue.main.async {
            self.attributedString = self.body.convertHtmlToAttributedStringWithCSS(font: UIFont(name: "Arial", size: 20), csscolor: "white", lineheight: 9, csstextalign: "natural") ?? NSAttributedString()
            self.textView.attributedText = self.attributedString
            self.activityIndicator.isHidden = true
            self.label.isHidden = false
            self.textView.isHidden = false
            self.goToSourceButton.isEnabled = true
            if !self.isFavScreenOpened { self.favoritesButton.isEnabled = true }
            self.shareButton.isEnabled = true
            print("✅после установки аттрибутированного текста")

        }
    }
    
    private func addToFavorites() {
        let manager = DataFileManager()
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
//        let dataOfAttributedString = manager.encodeNSAttribitedString(attributedString: attributedString)
        DispatchQueue.main.async {
            do {
                try manager.saveArticleData(ArticleData(labelText: self.header, bodyText: self.modifiedBody, url: self.url))
                self.activityIndicator.isHidden = true
                let alert = UIAlertController(title: "Saved to favorites", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
//                print("😆 Success")
            } catch {
                print(error)
                // покажи алерт....
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
        let safeFont = font ?? UIFont(name: "Arial", size: 20)!
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
