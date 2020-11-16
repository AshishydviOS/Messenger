//
//  UDManager.swift
//  Messenger
//
//  Created by Ashish Yadav on 14/11/20.
//

import Foundation

class UDManager{
    fileprivate static let SUITE_NAME = "GeneralUD"
    fileprivate static let IS_LOGIN = "isLogin"
    fileprivate static let TOKEN = "token"
    fileprivate static let USER_NAME = "userName"
    fileprivate static let USER_EMAIL = "userEmail"
    fileprivate static let USER_PROFILE_URL = "userProfileUrl"
    
    static let sharedInstance = UDManager()
    fileprivate init(){}
    
    fileprivate var userDefaults: UserDefaults{
        get{ return UserDefaults.init(suiteName: UDManager.SUITE_NAME) ?? UserDefaults.standard }
    }
    
    var token:String{
        get{ if let value = userDefaults.string(forKey: UDManager.TOKEN){
                return value
            }else{
                return ""
            }
        }
        set{ userDefaults.set(newValue, forKey: UDManager.TOKEN)}
    }
    
    var isLogin :Bool{
        get{ return userDefaults.bool(forKey: UDManager.IS_LOGIN)}
        set{ userDefaults.set(newValue, forKey: UDManager.IS_LOGIN)}
    }
    
    var userName : String{
        get{ if let value = userDefaults.string(forKey: UDManager.USER_NAME){
            return value
        }else{return ""}
        }
        set{ userDefaults.set(newValue, forKey: UDManager.USER_NAME)}
    }
    
    var userEmail : String{
           get{ if let value = userDefaults.string(forKey: UDManager.USER_EMAIL){
               return value
           }else{return ""}
           }
           set{ userDefaults.set(newValue, forKey: UDManager.USER_EMAIL)}
    }
    
    var userProfileUrl : String{
        get{ if let value = userDefaults.string(forKey: UDManager.USER_PROFILE_URL){
            return value
        }else{return ""}
        }
        set{ userDefaults.set(newValue, forKey: UDManager.USER_PROFILE_URL)}
    }
    
    
    func clearLoginData(){
        userDefaults.set(false, forKey: UDManager.IS_LOGIN)
        userDefaults.set("", forKey: UDManager.USER_NAME)
        userDefaults.set("", forKey: UDManager.USER_EMAIL)
        userDefaults.set("", forKey: UDManager.TOKEN)
        userDefaults.set("", forKey: UDManager.USER_PROFILE_URL)
    }
    
}
