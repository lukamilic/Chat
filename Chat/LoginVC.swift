//
//  ViewController.swift
//  Chat
//
//  Created by Luka Milic on 3/7/17.
//  Copyright © 2017 Luka Milic. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
   
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectProfileImg))
        profileImg.isUserInteractionEnabled = true
        profileImg.addGestureRecognizer(tapGestureRecognizer)
        
        usernameTextField.autocorrectionType = UITextAutocorrectionType.no
        emailTextField.autocorrectionType = UITextAutocorrectionType.no
        passwordTextField.autocorrectionType = UITextAutocorrectionType.no
        
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //showActivityIndicatory(uiView: self.view)
        
    }
    
    func showActivityIndicatory(uiView: UIView) {
      
        let loadingView: UIView = UIView()
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColor.lightGray
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRect(x: 0, y: 0, width: 40, height: 40);
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        actInd.center = CGPoint(x :loadingView.frame.size.width / 2,
                                y :loadingView.frame.size.height / 2)
        loadingView.addSubview(actInd)
        self.view.addSubview(loadingView)
        actInd.startAnimating()
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        usernameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        return true
    }
    
    func selectProfileImg() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImg = info["UIImagePickerControllerEditedImage"] as? UIImage {
            
            selectedImageFromPicker = editedImg
            
        } else if let originalImg = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImg
        }
        
        if let selectedImage = selectedImageFromPicker {
            
            profileImg.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func registerBtn(_ sender: Any) {
        self.showActivityIndicatory(uiView: self.view)
        guard let userName = usernameTextField.text, let email = emailTextField.text, let password = passwordTextField.text else {
            
            return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            let imgName = NSUUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("\(imgName).jpg")
            
            if let profileImage = self.profileImg.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.2) {
                
                storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                    
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    if let profileimgUrl = metadata?.downloadURL()?.absoluteString {
                        
                        let values = ["name":userName, "email":email, "profileImgUrl":profileimgUrl]
                        
                        self.registerUserInDatabaseWithUid(uid: uid, values: values)
                        
                        
                    }
                    
                })
            }
        })
    }
    
    func registerUserInDatabaseWithUid(uid: String, values: [String:Any]) {
        
        let ref = FIRDatabase.database().reference()
        let usersRef = ref.child("users").child(uid)
        usersRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print("error")
                return
            }
            self.dismiss(animated: true, completion: nil)
            // saved into firebase database
        })
    }
    
    @IBAction func loginBtn(_ sender: Any) {
        self.showActivityIndicatory(uiView: self.view)
        guard  let email = emailTextField.text, let password = passwordTextField.text else {
            
            print("not valid")
            return
        }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                
                print(error.debugDescription)
                return
            }
            
            // loged in
            self.dismiss(animated: true, completion: nil)
            
        })
    }
    
}

