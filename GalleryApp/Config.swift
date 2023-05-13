//
//  Config.swift
//  GalleryApp
//
//  Created by Mohit Kumar on 13/05/23.
//

import UIKit

public var GalleryView = GalleryViewConfig()

public class GalleryViewConfig {
    public var resultCallBack:(([String:Any]) -> ())?
    public var navigation: UINavigationController?
    public var isNaigationControllerPresent = false
    public var isNaigationControllerAnimated = true
}

//MARK: Navigation
public extension GalleryViewConfig {
    func present(with navigationController: UINavigationController, animated: Bool = true) {
        self.isNaigationControllerPresent = true
        self.isNaigationControllerAnimated = animated
        self.navigation = navigationController
        self.launchGallery()
    }
    
    func push(with navigationController: UINavigationController) {
        self.navigation = navigationController
        self.launchGallery()
    }
}

private extension GalleryViewConfig {
    func launchGallery() {
        let podBundle = Bundle(for: PhotoGalleryVC.self)
        let storyBoard = UIStoryboard.init(name: "GalleryApp", bundle: podBundle)
        let vc = storyBoard.instantiateViewController(withIdentifier: "PhotoGalleryVC") as? PhotoGalleryVC
        if self.isNaigationControllerPresent {
            vc?.modalPresentationStyle = .fullScreen
            self.navigation?.present(vc!, animated: self.isNaigationControllerAnimated, completion: nil)
        } else {
            self.navigation?.pushViewController(vc!, animated: self.isNaigationControllerAnimated)
        }
    }
}
