//
//  UIImageView+Extension.swift
//  GalleryApp
//
//  Created by Mohit Kumar on 10/03/23.
//

import UIKit
import Photos

extension UIImageView {
    func fetchImage(asset: PHAsset, contentMode: PHImageContentMode, targetSize: CGSize) {
        let options = PHImageRequestOptions()
        options.version = .original
        PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: options) { image, _ in
            guard let image = image else { return }
            switch contentMode {
            case .aspectFill:
                self.contentMode = .scaleAspectFill
            case .aspectFit:
                self.contentMode = .scaleAspectFit
            @unknown default:
                break
            }
            
            self.image = image
        }
    }
}


extension PHAsset {
    var primaryResource: PHAssetResource? {
        let types: Set<PHAssetResourceType>

        switch mediaType {
        case .video:
            types = [.video, .fullSizeVideo]
        case .image:
            types = [.photo, .fullSizePhoto]
        case .audio:
            types = [.audio]
        case .unknown:
            types = []
        @unknown default:
            types = []
        }

        let resources = PHAssetResource.assetResources(for: self)
        let resource = resources.first { types.contains($0.type)}

        return resource ?? resources.first
    }

    var originalFilename: String {
        guard let result = primaryResource else {
            return "file"
        }

        return result.originalFilename
    }
}
