//
//  CatalogCell.swift
//  HomeworkFileManager
//
//  Created by Kirill Manuilenko on 8.02.23.
//

import UIKit
import SnapKit

class CatalogFolderCell: UITableViewCell {
    
    //MARK: - Outlet and Variables
    
    static let key = "CatalogFolderCell"
    
    lazy var nameCatalogLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var imageCatalog: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "folder.fill")
        image.tintColor = UIColor(red: 55/255, green: 150/255, blue: 193/255, alpha: 1)
        return image
    }()

    //MARK: - Method
    
    func configure(with text: String) {
        nameCatalogLabel.text = text
    }
    
    //Setup UILabel and UIImageView
    func setupLabelAndImage() {
        contentView.addSubview(nameCatalogLabel)
        contentView.addSubview(imageCatalog)
        imageCatalog.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(16)
            make.leading.equalToSuperview().inset(16)
        }
        nameCatalogLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(16)
            make.leading.equalTo(imageCatalog.snp.trailing).offset(8)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLabelAndImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
