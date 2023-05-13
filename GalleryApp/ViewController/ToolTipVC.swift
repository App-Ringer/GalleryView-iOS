//
//  ToolTipVC.swift
//  GalleryApp
//
//  Created by Sourav Mishra on 11/03/23.
//

import UIKit
import Photos

class ToolTipVC: UIViewController {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    
    var selectedAsset: PHAsset!
    var goToImageDetailClosure: ((PHAsset)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
   @IBAction func goToImageDetail(sender: UIButton) {
       self.dismiss(animated: true)
       goToImageDetailClosure?(selectedAsset)
    }
    
}
