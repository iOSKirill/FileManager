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
    
    lazy var imageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.maximumZoomScale = 10
        return scrollView
    }()
    
    lazy var imageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()
    

    //MARK: - Method -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImage()
        setupImageScrollView()
    }
    
    func setupImageScrollView() {
        imageScrollView.delegate = self
    }
    
    func setupImage() {
        view.addSubview(imageScrollView)
        imageScrollView.snp.makeConstraints { make in
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.top.equalTo(view.snp.top)
            make.bottom.equalTo(view.snp.bottom)
        }
        
        imageScrollView.addSubview(imageStackView)
        imageStackView.snp.makeConstraints { make in
            make.leading.equalTo(imageScrollView.snp.leading)
            make.trailing.equalTo(imageScrollView.snp.trailing)
            make.centerY.equalTo(imageScrollView.snp.centerY)
          
            make.width.equalTo(imageScrollView.snp.width)
        }
        
        imageStackView.addArrangedSubview(imageCatalog)
        imageCatalog.snp.makeConstraints { make in
            make.width.equalTo(imageStackView.snp.width)
            make.height.equalTo(400)
        }
        
    }
}

extension ImageViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageCatalog
    }
}

