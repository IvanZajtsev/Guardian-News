//
//  HeaderCell.swift
//  MD News
//
//  Created by Иван Зайцев on 29.03.2022.
//

import UIKit

class HeaderCell: UITableViewCell {
    
    private enum Constants {
        static let inset: CGFloat = 10
    }
    static let identifier = "reusableCell"
    
    // MARK: - Private data structures
    
//    @IBOutlet weak var pictureImageView: UIImageView!
    
    lazy var pictureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        print("🟦 init lazy var")
        return imageView
    }()
    
//    @IBOutlet weak var headerLabel: UILabel!
    
    lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.numberOfLines = 0
//        label.backgroundColor = .darkGray
        
        return label
    }()
    
//    @IBOutlet weak var trailingContextLabel: UILabel!
    
    lazy var trailingContextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.numberOfLines = 0

        
        return label
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    // MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        contentView.addSubview(pictureImageView)
        contentView.addSubview(headerLabel)
        contentView.addSubview(trailingContextLabel)
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(headerLabel)
        stackView.addArrangedSubview(trailingContextLabel)
        
        let constraints = [
            pictureImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.inset),
            pictureImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pictureImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            // делаю вид что ширина сама как-то сделается
            pictureImageView.heightAnchor.constraint(equalTo: pictureImageView.widthAnchor, multiplier: 3 / 5, constant: 0),
            // выше типа щазаписано aspect ratio
            stackView.topAnchor.constraint(equalTo: pictureImageView.bottomAnchor, constant: Constants.inset),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.inset),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.inset),
            // сделаем пока руками ширину
            stackView.heightAnchor.constraint(equalToConstant: 200)

        ]
        
        NSLayoutConstraint.activate(constraints)

        
    }
    
    
}
