//
//  CollectionCatalogImageCell.swift
//  HomeworkFileManager
//
//  Created by Kirill Manuilenko on 16.02.23.
//

import UIKit

class CollectionCatalogImageCell: UICollectionViewCell {

    static let key = "CollectionCatalogImageCell"
    
    lazy var thumbnailImage: UIImageView = {
        let image = UIImageView()
        return image
    }()
    
    //MARK: - Method
    
    func setupImage() {
        contentView.addSubview(thumbnailImage)
        thumbnailImage.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImage()
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
