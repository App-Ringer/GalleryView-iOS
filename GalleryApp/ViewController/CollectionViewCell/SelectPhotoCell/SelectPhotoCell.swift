//
//  SelectPhotoCell.swift
//  PhotosDemo
//
//  Created by Sourav Mishra on 08/03/23.
//

import UIKit

class SelectPhotoCell: UICollectionViewCell {
    //MARK: - IBOutlet -
    @IBOutlet weak var imgPicture: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //MARK: - Populate Data -
    func setData(photoGalleryVM: PhotoGalleryVM, assetModel: ImageAssetVM, indexPath: IndexPath) {
        imgPicture.image = assetModel.image
        contentView.layer.borderColor = UIColor.red.cgColor
        if let indexP = photoGalleryVM.selectedIndex, indexP == indexPath {
            contentView.layer.borderWidth = 1
        } else {
            contentView.layer.borderWidth = 0
        }
    }
    
}
