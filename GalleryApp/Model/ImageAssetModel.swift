//
//  ImageAssetModel.swift
//  GalleryApp
//
//  Created by Sourav Mishra on 17/03/23.
//

import Photos
import UIKit

struct ImageAssetModel {
    var creationDate: Date
    var asset: PHAsset
    var image: UIImage = UIImage()
    var isToolTip: Bool = false
    var isDummyCell: Bool = false
    var fileName: String = ""
    var fileType: String = ""
    
    init(assest: PHAsset) {
        self.creationDate = assest.creationDate ?? Date()
        self.asset = assest
    }
}
