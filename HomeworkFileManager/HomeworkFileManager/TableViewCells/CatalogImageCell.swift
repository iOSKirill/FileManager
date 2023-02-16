//
//  CatalogImageCell.swift
//  HomeworkFileManager
//
//  Created by Kirill Manuilenko on 13.02.23.
//

import UIKit

class CatalogImageCell: UITableViewCell {
    
    //MARK: - Outlet and Variables -
    
    static let key = "CatalogImageCell"
    
    lazy var thumbnailImage: UIImageView = {
        let image = UIImageView()
        return image
    }()
    
    //MARK: - Method
    
    func setupImage() {
        contentView.addSubview(thumbnailImage)
        thumbnailImage.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
