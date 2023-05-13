//
//  ImageAssetVM.swift
//  GalleryApp
//
//  Created by Mohit Kumar on 01/05/23.
//

import UIKit
import Photos

class ImageAssetVM {
    var assetModel: ImageAssetModel!
    
    init(model: ImageAssetModel) {
        self.assetModel = model
    }
    
    var creationDate: Date {
        return self.assetModel.creationDate
    }
    
    var asset: PHAsset {
        return self.assetModel.asset
    }
    
    var image: UIImage {
        return self.assetModel.image
    }
    
    var isToolTip: Bool {
        return self.assetModel.isToolTip
    }
    
    
    var isDummyCell: Bool {
        return self.assetModel.isDummyCell
    }
    
    var fileName: String {
        return self.assetModel.fileName
    }
    
    var fileType: String {
        return self.assetModel.fileType
    }
}
