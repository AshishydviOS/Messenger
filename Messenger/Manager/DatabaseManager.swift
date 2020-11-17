//
//  DatabaseManager.swift
//  Messenger
//
//  Created by Ashish Yadav on 14/11/20.
//

import Foundation
import Firebase


//final class means it can not be subclass
class  DatabaseManager {
    static let shared = DatabaseManager()
    var database: DatabaseReference = Database.database().reference()
    
    public func safeEmail(emailAddress : String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

//MARK: Account Management
extension DatabaseManager {
    
    public func userExists(with email : String,
                           completion : @escaping((Bool) -> Void)) {
        
        //This is required because firebase will cause an error if string contain '.' '#' '$' '[' or ']'
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value) { (snapshot) in
            guard snapshot.value as? NSDictionary != nil else {
                LogManager.sharedInstance.logVerbose(#file, methodName: #function, logMessage: "New user")
                completion(false)
                return
            }
            LogManager.sharedInstance.logVerbose(#file, methodName: #function, logMessage: "Existing user")
            completion(true)
        }
    }
    
    /// insert new user to database
    public func insertUser(with user : ChatAppUser, completion : @escaping (Bool) -> Void) {
        LogManager.sharedInstance.logVerbose(#file, methodName: #function, logMessage: "Insert user")
        database = Database.database().reference()
        database.child(user.safeEmail).setValue([
            "first_name" : user.firstName,
            "last_name" : user.lastName
        ]) { (error, _) in
            guard error == nil else {
                print("failed to write to database")
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value) { (snapshot) in
                if var userCollection = snapshot.value as? [[String:String]] {
                    //append to user dictionary
                    let newElement = [
                        "name" : user.firstName + " " + user.lastName,
                        "email" : user.safeEmail
                    ]
                    userCollection.append(newElement)
                    
                    self.database.child("users").setValue(userCollection) { (error, _) in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                }
                else {
                    //Create that array
                    let newCollection : [[String : String]] = [
                        [
                            "name" : user.firstName + " " + user.lastName,
                            "email" : user.safeEmail
                        ]
                    ]
                    self.database.child("users").setValue(newCollection) { (error, _) in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                }
            }
            
            
            /*
             users => [
                [
                    "name" :
                    "safe_email" :
                ],
                [
                    "name" :
                    "safe_email" :
                ]
             ]
             */
        }
    }
    
    public func getAllUsers(completion : @escaping (Result<[[String:String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? [[String : String]] else {
                completion(.failure(DatabaseErrors.FailedToFetch))
                return
            }
            
            completion(.success(value))
        }
    }
    
    public enum DatabaseErrors : Error {
        case FailedToFetch
    }
    
}

struct ChatAppUser {
    let firstName       : String
    let lastName        : String
    let emailAddress    : String
    var safeEmail : String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var profilePictureFileName : String {
        //ashish-yadav-gmail-com_Profile_Picture.png
        return "\(safeEmail)_profile_picture.png"
    }
}
