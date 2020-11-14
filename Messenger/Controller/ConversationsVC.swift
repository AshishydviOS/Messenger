//
//  ConversationsVC.swift
//  Messenger
//
//  Created by Ashish Yadav on 12/11/20.
//

import UIKit
import Firebase

class ConversationsVC : UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
        
    }
    
    private func validateAuth() {
        LogManager.sharedInstance.logVerbose(#file, methodName: #function, logMessage: "User Validation function called")
        //Check if No Firebase user available and
        if Firebase.Auth.auth().currentUser == nil { //&& UDManager.sharedInstance.isLogin == false {
            LogManager.sharedInstance.logVerbose(#file, methodName: #function, logMessage: "No Current user found. Navigate to login.")
            let vc = LoginVC()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }

}

