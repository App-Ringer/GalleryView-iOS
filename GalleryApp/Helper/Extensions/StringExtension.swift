//
//  StringExtension.swift
//  GalleryApp
//
//  Created by Sourav Mishra on 10/03/23.
//

import Foundation

extension String {
    func convertStringToDate(formate: String = "yyyy-MM-dd") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formate
        let date = dateFormatter.date(from:self)!
        
        return date
    }
}
