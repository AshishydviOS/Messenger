//
//  AppDelegate.swift
//  Messenger
//
//  Created by Ashish Yadav on 12/11/20.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //FireBase Setup
        FirebaseApp.configure()
        
        //MARK: Setup Logmanager
        LogManager.sharedInstance.initLogger()
        
        return true
    }


}

