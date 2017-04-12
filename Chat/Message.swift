//
//  Message.swift
//  Chat
//
//  Created by Luka Milic on 3/16/17.
//  Copyright © 2017 Luka Milic. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    
    var fromId: String?
    var toId: String?
    var text: String?
    var timestamp: NSNumber?
    var imageUrl: String?
    var imgWidth: NSNumber?
    var imgHeight: NSNumber?
    
    func chatPartner() -> String? {
  
        if fromId == FIRAuth.auth()?.currentUser?.uid {
            return toId
        } else {
            return fromId
        }
    }
    
     init(dict: [String:Any]) {
        super.init()
        
        fromId = dict["fromId"] as? String
        text = dict["text"] as? String
        toId = dict["toId"] as? String
        timestamp = dict["timestamp"] as? NSNumber
        
        imageUrl = dict["imageUrl"] as? String
        imgWidth = dict["imgWidth"] as? NSNumber
        imgHeight = dict["imgHeight"] as? NSNumber
        
    }
}
