//
//  ChatLogVC.swift
//  Chat
//
//  Created by Luka Milic on 3/14/17.
//  Copyright © 2017 Luka Milic. All rights reserved.
//

import UIKit
import Firebase

class ChatLogVC: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var user: User? {
        
        didSet {
            navigationItem.title = user?.name
            
            observeMsgs()
        }
    }
    
    var messages = [Message]()
    
    func observeMsgs() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let userMsgRef = FIRDatabase.database().reference().child("user-messages").child(uid)
        userMsgRef.observe(.childAdded, with: { (snapshot) in
            
            let msgId = snapshot.key
            let messagesRef = FIRDatabase.database().reference().child("messages").child(msgId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dict = snapshot.value as? [String:Any] else {
                    return
                }
                
                let message = Message(dict: dict)                
                if message.chatPartner() == self.user?.id {
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                        let indexPath = NSIndexPath(item: self.messages.count - 1, section: 0)
                        self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
                    }
                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    lazy var inputTextField : UITextField = {
        
        let textField = UITextField()
        textField.placeholder = "Enter message.."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.autocorrectionType = .no
        return textField
    }()
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMsgCell.self, forCellWithReuseIdentifier: cellId)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        inputTextField.delegate = self
        
        setupView()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMsgCell
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        
        if let profImgUrl = self.user?.profileImgUrl {
            cell.profImgView.cacheImgWithUrl(urlString: profImgUrl)
        }
        
        if message.fromId == FIRAuth.auth()?.currentUser?.uid {
            
            cell.bubbleView.backgroundColor = UIColor.blue
            cell.textView.textColor = UIColor.white
            cell.profImgView.isHidden = true
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            
        } else {
            
            cell.bubbleView.backgroundColor = UIColor.lightGray
            cell.textView.textColor = UIColor.black
            cell.profImgView.isHidden = false
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
        
        if let text = message.text {
            
            cell.bubbleWidth?.constant = frameForText(text: text).width + 35

        } else if message.imageUrl != nil {
            
            cell.bubbleWidth?.constant = 200
        }
        
        if let msgImgUrl = message.imageUrl {
            cell.msgImgView.cacheImgWithUrl(urlString: msgImgUrl)
            cell.msgImgView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        } else {
            cell.msgImgView.isHidden = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        let message = messages[indexPath.item]
        if let text = message.text {
            
            height = frameForText(text: text).height + 20
        } else if let imgWidth = message.imgWidth?.floatValue, let imgHeight = message.imgHeight?.floatValue {
            
            height = CGFloat(imgHeight / imgWidth * 200)
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func frameForText(text: String) -> CGRect {
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    func setupView() {
        
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let uploadImage = UIImageView()
        uploadImage.image = UIImage(named: "1491771835_picture-1")
        uploadImage.isUserInteractionEnabled = true
        uploadImage.translatesAutoresizingMaskIntoConstraints = false
        uploadImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(uploadTap)))
        containerView.addSubview(uploadImage)
        
        uploadImage.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        uploadImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImage.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImage.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        
        let sendBtn = UIButton(type: UIButtonType.system)
        sendBtn.setTitle("Send", for: .normal)
        sendBtn.translatesAutoresizingMaskIntoConstraints = false
        sendBtn.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        containerView.addSubview(sendBtn)
        
        sendBtn.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendBtn.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendBtn.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendBtn.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
    
        containerView.addSubview(inputTextField)
        
        inputTextField.leftAnchor.constraint(equalTo: uploadImage.rightAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendBtn.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLine = UIView()
        separatorLine.backgroundColor = UIColor.lightGray
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLine)
        
        separatorLine.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLine.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLine.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
    
    func uploadTap() {
        
        let imgPickerController = UIImagePickerController()
        
        imgPickerController.allowsEditing = true
        imgPickerController.delegate = self
        
        present(imgPickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImg = info["UIImagePickerControllerEditedImage"] as? UIImage {
            
            selectedImageFromPicker = editedImg
            
        } else if let originalImg = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImg
        }
        
        if let selectedImage = selectedImageFromPicker {
            
            uploadToFirebaseStorage(image: selectedImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func uploadToFirebaseStorage(image: UIImage) {
        
        let imgName = NSUUID().uuidString
        let ref = FIRStorage.storage().reference().child("msg_images").child(imgName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            
            ref.put(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print("failed")
                    return
                }
                
                if let imgUrl = metadata?.downloadURL()?.absoluteString {
                    
                    self.sendMsgWithImgUrl(imgUrl: imgUrl, img: image)
                }
            })
        }
        
    }
    
    func sendMsgWithImgUrl(imgUrl: String, img: UIImage) {
        
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timestamp = Int(NSDate().timeIntervalSince1970)
        
        let values = ["imageUrl":imgUrl, "imgWidth": img.size.width, "imgHeight": img.size.height, "toId":toId, "fromId":fromId, "timestamp":timestamp] as [String : Any]
        // childRef.updateChildValues(values)
        
        childRef.updateChildValues(values) { (error, ref) in
            
            if error != nil {
                
                print(error)
                return
            }
            
            let userMsgRef = FIRDatabase.database().reference().child("user-messages").child(fromId)
            
            let msgId = childRef.key
            userMsgRef.updateChildValues([msgId: 1])
            
            let recipeUserMsgRef = FIRDatabase.database().reference().child("user-messages").child(toId)
            recipeUserMsgRef.updateChildValues([msgId: 1])
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func sendMessage() {
        
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timestamp = Int(NSDate().timeIntervalSince1970)
        let values = ["text":inputTextField.text!, "toId":toId, "fromId":fromId, "timestamp":timestamp] as [String : Any]
       // childRef.updateChildValues(values)
        
        childRef.updateChildValues(values) { (error, ref) in
            
            if error != nil {
                
                print(error)
                return
            }
            
            let userMsgRef = FIRDatabase.database().reference().child("user-messages").child(fromId)
            
            let msgId = childRef.key
            userMsgRef.updateChildValues([msgId: 1])
            
            let recipeUserMsgRef = FIRDatabase.database().reference().child("user-messages").child(toId)
            recipeUserMsgRef.updateChildValues([msgId: 1])
        }
        
        inputTextField.text = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        sendMessage()
        inputTextField.resignFirstResponder()
        return true
    }
}













