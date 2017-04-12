//
//  ViewController.swift
//  Chat
//
//  Created by Luka Milic on 3/12/17.
//  Copyright © 2017 Luka Milic. All rights reserved.
//

import UIKit
import Firebase

class AllMsg: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(newMessage))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: "cellId")
        
       // observeMsg()
        
        
    }
    
    var timer: Timer?
    
    func reloadTable() {
        
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
        }
    }
    
    func observeUserMsg() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            
            return
        }
        
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let msgId = snapshot.key
            let messageRef = FIRDatabase.database().reference().child("messages").child(msgId)
            
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dict = snapshot.value as? [String:Any] {
                    let message = Message(dict: dict)
                   
                    if let chatPartner = message.chatPartner() {
                        
                        self.messagesDict[chatPartner] = message
                        self.messages = Array(self.messagesDict.values)
                        self.messages.sort(by: { (msg1, msg2) -> Bool in
                            
                            return msg1.timestamp!.intValue > msg2.timestamp!.intValue
                        })
                    }
                    
                    self.timer?.invalidate()
                    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.reloadTable), userInfo: nil, repeats: false)
                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    var messages = [Message]()
    var messagesDict = [String: Message]()
    
    
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages.count
    }
    
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! UserCell
        cell.selectionStyle = .none
        
        
        let message = messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 72
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        print(message.text as Any)
        
        guard let chatPartner = message.chatPartner() else {
            return
            
        }
        
        let ref = FIRDatabase.database().reference().child("users").child(chatPartner)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dict = snapshot.value as? [String:Any] else {
                return
            }
            let user = User()
            user.id = chatPartner
            user.setValuesForKeys(dict)
            self.showChatVCforUser(user: user)
            
        }, withCancel: nil)
        
        
    }
    
    func setupNavBar(user: User) {
        
        messages.removeAll()
        messagesDict.removeAll()
        tableView.reloadData()
        
        observeUserMsg()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        titleView.backgroundColor = UIColor.clear
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        if let profileImageUrl = user.profileImgUrl {
            profileImageView.cacheImgWithUrl(urlString: profileImageUrl)
        }
        
        containerView.addSubview(profileImageView)
        
        // Constraint anchors
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Constraint anchors
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        
        //titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatVC)))

    }
    
    func showChatVCforUser(user: User) {
        
        let chatLogVC = ChatLogVC(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogVC.user = user
        navigationController?.pushViewController(chatLogVC, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
    
        checkIfUserIsLogged()
    }
    
    func newMessage() {
        
        let newMsgVC = NewMsgVC()
        newMsgVC.newMsgcontroller = self
        let navController = UINavigationController(rootViewController: newMsgVC)
        present(navController, animated: true, completion: nil)
    }
    
    func checkIfUserIsLogged() {
        
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(logout), with: nil, afterDelay: 0)
        } else {
            let uid = FIRAuth.auth()?.currentUser?.uid
            FIRDatabase.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dict = snapshot.value as? [String:Any] {
                self.navigationItem.title = dict["name"] as? String
                    
                    let user = User()
                    user.setValuesForKeys(dict)
                    self.setupNavBar(user: user)
                }
                
            }, withCancel: nil)
        }
        
    }
    
    func logout() {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
        present(loginVC!, animated: true, completion: nil)
    }
   
}
