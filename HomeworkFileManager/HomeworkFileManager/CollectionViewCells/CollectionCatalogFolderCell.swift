//
//  CollectionCatalogFolderCell.swift
//  HomeworkFileManager
//
//  Created by Kirill Manuilenko on 16.02.23.
//

import UIKit
import SnapKit

class CollectionCatalogFolderCell: UICollectionViewCell {
    
    //MARK: - Outlet and Variables -
    
    static let key = "CollectionCatalogFolderCell"
    
    lazy var nameCatalogLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    lazy var imageCatalog: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "folder.fill")
        image.tintColor = UIColor(red: 55/255, green: 150/255, blue: 193/255, alpha: 1)
        return image
    }()
    
    //MARK: - Method -
    
    func setupLabelAndImage() {
        contentView.addSubview(nameCatalogLabel)
        contentView.addSubview(imageCatalog)
        imageCatalog.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.centerX.equalToSuperview()
        }
        nameCatalogLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(5)
            make.centerX.equalToSuperview()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabelAndImage()
        contentView.layer.cornerRadius = 10
        contentView.backgroundColor = .systemIndigo
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
