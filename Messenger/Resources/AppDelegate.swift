//
//  AppDelegate.swift
//  Messenger
//
//  Created by Ashish Yadav on 12/11/20.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //FireBase Intilization
        FirebaseApp.configure()
        
        //IQKeyboardManager Intilization
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        //LogManager Intilization
        LogManager.sharedInstance.initLogger()
        
        //Sign In with google Intilization
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
        
        return true
    }
    
    func sign(_ signIn: GIDSignIn!,
              didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }
        
//         Perform any operations on signed in user here.
//        let userId        = user.userID                  // For client-side use only!
//        let idToken       = user.authentication.idToken // Safe to send to the server
//        let fullName      = user.profile.name
//        let givenName     = user.profile.givenName
//        let familyName    = user.profile.familyName
//        let email         = user.profile.email
        
        if let user = user {
            print("Did sign in with Google : \(user)")
        }
        
        if let email = user.profile.email,
           let firstName = user.profile.givenName,
           let lastName = user.profile.familyName {
            
            DatabaseManager.shared.userExists(with: email) { (existing) in
                if !existing {
                    //New User : insert to database
                    DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName,
                                                                        lastName: lastName,
                                                                        emailAddress: email))
                }
            }
        }
        
        guard let authentication = user.authentication else {
            print("Missing auth object off of google user")
            return
        }
        let credential =  GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                        accessToken: authentication.accessToken)
        
        Firebase.Auth.auth().signIn(with: credential) { (authResult, error) in
            guard authResult != nil, error == nil else {
                print("Failed to log in with google credential")
                return
            }
            
            //Success
            print("Successfully signed in with google credential")
            NotificationCenter.default.post(name: .didLogInNotification,
                                            object: nil)
        }
    }
    
    func sign(_ signIn: GIDSignIn!,
              didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        print("Google user was disconneted")
      
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        
        return GIDSignIn.sharedInstance().handle(url)
    }

}
