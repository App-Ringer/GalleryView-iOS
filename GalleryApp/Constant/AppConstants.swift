//
//  AppConstants.swift
//  GalleryApp
//
//  Created by Mohit Kumar on 13/03/23.
//

import Foundation
import UIKit

let PORTRAIT_MODE_MIN: CGFloat = 2
let PORTRAIT_MODE_MAX: CGFloat = 4

let LANDSCAPE_MODE_MIN: CGFloat = 4
let LANDSCAPE_MODE_MAX: CGFloat = 7

let PAGE_SIZE: Int = 5

public func delay(delay:Double, closure: @escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}
