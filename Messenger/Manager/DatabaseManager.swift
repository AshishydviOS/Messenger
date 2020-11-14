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
}

//MARK: Account Management
extension DatabaseManager {
    
    public func userExists(with email : String,
                           completion : @escaping((Bool) -> Void)) {
        
        //This is required because firebase will cause an error if string contain '.' '#' '$' '[' or ']'
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value) { (snapshot) in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    /// insert new user to database
    public func insertUser(with user : ChatAppUser) {
        database = Database.database().reference()
        database.child(user.safeEmail).setValue([
            "first_name" : user.firstName,
            "last_name" : user.lastName
        ])
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
//    let profilePictureUrl : String
}
