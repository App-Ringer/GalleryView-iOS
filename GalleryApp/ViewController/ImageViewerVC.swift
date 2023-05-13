//
//  ImageViewerVC.swift
//  GalleryApp
//
//  Created by Sourav Mishra on 11/03/23.
//

import UIKit

class ImageViewerVC: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var image: UIImage = UIImage()
    var isInfoGrapic: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        img.image = image
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        
        scrollView.contentSize = .init(width: 2000, height: 2000)
        updateZoomFor(size: view.bounds.size)
    }
    
    @IBAction func closeAction(sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return img
    }
    
    func updateZoomFor(size: CGSize){
        let widthScale = size.width / img.bounds.width
        let heightScale = size.height / img.bounds.height
        let scale = min(widthScale,heightScale)
        scrollView.minimumZoomScale = scale
    }
}
