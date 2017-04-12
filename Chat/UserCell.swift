//
//  UserCell.swift
//  Chat
//
//  Created by Luka Milic on 3/20/17.
//  Copyright © 2017 Luka Milic. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    var message: Message? {
        
        didSet {
            
            setupNameAndImg()
            
            detailTextLabel?.text = message?.text
            
            if let seconds = message?.timestamp?.doubleValue {
                
                let timestampDate = NSDate(timeIntervalSince1970: seconds)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                timeLbl.text = dateFormatter.string(from: timestampDate as Date)
            }
            
        }
    }
    
    private func setupNameAndImg() {
       
        
        if let Id = message?.chatPartner() {
            let ref = FIRDatabase.database().reference().child("users").child(Id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dict = snapshot.value as? [String:Any] {
                    
                    self.textLabel?.text = dict["name"] as? String
                    
                    if let profileImgUrl = dict["profileImgUrl"] as? String {
                        
                        self.profImgView.cacheImgWithUrl(urlString: profileImgUrl)
                    }
                }
                
            }, withCancel: nil)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
        
        
    }
    
    let profImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.layer.cornerRadius = 24
        imgView.layer.masksToBounds = true
        imgView.contentMode = .scaleAspectFill
        return imgView
    }()
    
    let timeLbl: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style:UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profImgView)
        addSubview(timeLbl)
        
        profImgView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profImgView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profImgView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profImgView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        timeLbl.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        timeLbl.centerYAnchor.constraint(equalTo: self.topAnchor, constant: 25).isActive = true
        timeLbl.widthAnchor.constraint(equalToConstant: 110).isActive = true
        timeLbl.heightAnchor.constraint(equalTo: textLabel!.heightAnchor).isActive = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
