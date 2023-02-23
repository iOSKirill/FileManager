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
    var imageArray: [UIImage] = []
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!

    //MARK: - Method -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImage()
    }
    
    func setupImage() {
        scrollView.delegate = self
        imageArray.forEach { image in
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            stackView.addArrangedSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.width.equalTo(view)
                make.height.equalTo(view).inset(50)
            }
        }
    }
}

extension ImageViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        stackView
    }
}

