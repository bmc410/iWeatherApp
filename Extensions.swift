//
//  Extensions.swift
//  WeatherApp
//
//  Created by Bill McCoy on 5/12/16.
//  Copyright © 2016 WellSpan Health. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    public func imageFromUrl(urlString: String) {
        if let url = NSURL(string: urlString) {
            let request = NSURLRequest(URL: url)
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                if let imageData = data as NSData? {
                    self.image = UIImage(data: imageData)
                }
            }
            task.resume()
        }
    }
}