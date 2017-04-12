//
//  ChatMsgCell.swift
//  Chat
//
//  Created by Luka Milic on 3/31/17.
//  Copyright © 2017 Luka Milic. All rights reserved.
//

import UIKit

class ChatMsgCell: UICollectionViewCell {
    
    let textView: UITextView = {
        
        let tView = UITextView()
        tView.text = "dsadsad"
        tView.font = UIFont.systemFont(ofSize: 17)
        tView.translatesAutoresizingMaskIntoConstraints = false
        tView.backgroundColor = UIColor.clear
        tView.textColor = UIColor.white
        tView.isEditable = false
        return tView
    }()
    
    let bubbleView: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor.blue
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let profImgView: UIImageView = {
        
        let imgView = UIImageView()
        imgView.image = UIImage(named: "imagePick")
        imgView.layer.cornerRadius = 16
        imgView.layer.masksToBounds = true
        imgView.contentMode = .scaleAspectFill
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    let msgImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.layer.cornerRadius = 16
        imgView.layer.masksToBounds = true
        imgView.contentMode = .scaleAspectFill
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    var bubbleWidth: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profImgView)
        
        bubbleView.addSubview(msgImgView)
        msgImgView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        msgImgView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        msgImgView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        msgImgView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
        profImgView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profImgView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profImgView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profImgView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10)
        bubbleViewRightAnchor?.isActive = true
        
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profImgView.rightAnchor, constant: 8)
        
        
        
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidth = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidth?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        
        //textView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
