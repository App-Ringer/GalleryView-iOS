//
//  ToolTipCell.swift
//  GalleryApp
//
//  Created by Sourav Mishra on 31/03/23.
//

import UIKit

class ToolTipCell: UICollectionViewCell {
    //MARK: - IBOutlet -
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tView.layer.cornerRadius = 10
    }
    
    //MARK: - Populate Data -
    func setData(photoGalleryVM: PhotoGalleryVM, assetModel: ImageAssetVM, cellWidth: CGFloat, rowCount: CGFloat) {
        if let selectedAssetIndex = photoGalleryVM.selectedIndex {
            let val = (selectedAssetIndex.row + 1) % Int(rowCount)
            if val == 0 {
                leftConstraint.constant = ((abs((CGFloat(rowCount) - 0.5)) * cellWidth) - 5)
            } else {
                leftConstraint.constant = ((abs((CGFloat(val) - 0.5)) * cellWidth) - 5)
            }
        }
        lblTitle.text = assetModel.fileName
        lblSubtitle.text = "Image Type: \(assetModel.fileType)"
    }
}
