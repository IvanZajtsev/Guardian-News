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
    var url: String?
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    static var picWidth = 0
    static var picHeight = 0
    
    @IBAction func goToSourceTapped(_ sender: UIBarButtonItem) {
        guard let url = url,
              let urlToOpen = URL(string: url) else {
                  return
        }
        if UIApplication.shared.canOpenURL(urlToOpen) {
             UIApplication.shared.open(urlToOpen, options: [:], completionHandler: nil)
        }
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
       
        
    }
    private func setupUI() {
        label.isHidden = true
        textView.isHidden = true
        activityIndicator.startAnimating()

        tabBarController?.tabBar.isHidden = true
        label.text = header

        ArticleViewController.picWidth = Int(round(textView.frame.size.width * 0.87))
        ArticleViewController.picHeight = Int(round(textView.frame.size.width * 0.87 * 0.6))
        print("🅰️до установки аттрибутированного текста")
        
        DispatchQueue.main.async {
            self.textView.attributedText = self.body.convertHtmlToAttributedStringWithCSS(font: UIFont(name: "Arial", size: 20), csscolor: "white", lineheight: 9, csstextalign: "natural")
            self.activityIndicator.isHidden = true
            self.label.isHidden = false
            self.textView.isHidden = false
            print("✅после установки аттрибутированного текста")

        }

        

    }
    
    
}



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

    public func convertHtmlToAttributedStringWithCSS(font: UIFont? , csscolor: String , lineheight: Int, csstextalign: String) -> NSAttributedString? {
        guard let font = font else {
            return convertHtmlToNSAttributedString
        }
        let modifiedString = "<style> img { width: \(ArticleViewController.picWidth)px; height: \(ArticleViewController.picHeight)px; } body{font-family: '\(font.fontName)'; font-size:\(font.pointSize)px; color: \(csscolor); line-height: \(lineheight)px; text-align: \(csstextalign); }</style>\(self)";
        print(modifiedString)
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
