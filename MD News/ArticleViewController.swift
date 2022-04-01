//
//  ArticleViewController.swift
//  MD News
//
//  Created by Иван Зайцев on 29.03.2022.
//

import Foundation
import UIKit

class ArticleViewController: UIViewController {
    var body: String?
    var header: String?
    var url: String?
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var textView: UITextView!
    
    
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
        label.text = header
        textView.contentMode = .scaleToFill
        textView.attributedText = body!.convertHtmlToAttributedStringWithCSS(font: UIFont(name: "Arial", size: 20), csscolor: "white", lineheight: 9, csstextalign: "natural")

        
    }
    
}

/*
extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue, .sourceTextScaling: "9" ], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
*/

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
        let modifiedString = "<style>body{font-family: '\(font.fontName)'; font-size:\(font.pointSize)px; color: \(csscolor); line-height: \(lineheight)px; text-align: \(csstextalign); }</style>\(self)";
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
