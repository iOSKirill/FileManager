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
    
    lazy var imageSelect: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "checkmark")
        image.tintColor = UIColor(red: 55/255, green: 150/255, blue: 193/255, alpha: 1)
        return image
    }()
    
    //MARK: - Method
    
    func setupImage() {
        contentView.addSubview(thumbnailImage)
        contentView.addSubview(imageSelect)
        thumbnailImage.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        imageSelect.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().inset(16)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupImage()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
        imageSelect.isHidden = !isSelected
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
