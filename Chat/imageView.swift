//
//  imageView.swift
//  Chat
//
//  Created by Luka Milic on 3/13/17.
//  Copyright © 2017 Luka Milic. All rights reserved.
//

import UIKit

let imgCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func cacheImgWithUrl(urlString: String) {
        
        self.image = nil
        
        if let cachedImg = imgCache.object(forKey: urlString as AnyObject) {
            self.image = cachedImg as? UIImage
            return
        }
        
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            if error != nil {
                print(error.debugDescription)
                return
            }
            
            DispatchQueue.main.async {
                
                if let downloadedImg = UIImage(data: data!) {
                
                imgCache.setObject(downloadedImg, forKey: urlString as AnyObject)
                    
                    self.image = downloadedImg
                    
                }
                
            }
            
        }).resume()
    }
}
