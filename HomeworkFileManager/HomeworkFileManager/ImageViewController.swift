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
    var imageView = UIImageView()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    //MARK: - Method -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImage()
    }
    
    func setupImage() {
        scrollView.delegate = self
        pageControl.numberOfPages = imageArray.count
        imageArray.forEach { image in
            imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            stackView.addArrangedSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.width.equalTo(view)
                make.height.equalTo(view).inset(50)
            }
        }
    }
    
    @IBAction func changePage(_ sender: Any) {
        let offset = CGFloat(pageControl.currentPage) * scrollView.frame.width
        scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
    }
}

extension ImageViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x/scrollView.frame.width))
        pageControl.currentPage = page
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        stackView
    }
    


}

