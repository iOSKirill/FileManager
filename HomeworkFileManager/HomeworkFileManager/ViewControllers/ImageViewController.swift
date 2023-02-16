//
//  ImageViewController.swift
//  HomeworkFileManager
//
//  Created by Kirill Manuilenko on 13.02.23.
//

import UIKit
import SnapKit

class ImageViewController: UIViewController {
    
    //MARK: - Outlet and Variables -
    
    static let key = "ImageViewController"
    
    lazy var imageCatalog: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        return image
    }()

    //MARK: - Method -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImage()
    }
    
    func setupImage() {
        view.addSubview(imageCatalog)
        imageCatalog.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(50)
        }
    }

}
