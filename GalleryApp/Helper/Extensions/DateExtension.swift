//
//  DateExtension.swift
//  GalleryApp
//
//  Created by Sourav Mishra on 10/03/23.
//

import Foundation

extension Date {
    func convertDateToString(formate: String = "yyyy-MM-dd") -> String {
        let df = DateFormatter()
        df.dateFormat = formate
        let dateString = df.string(from: self)
        return dateString
    }
}
