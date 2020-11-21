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
            FirebaseConstant.first_Name : user.firstName,
            FirebaseConstant.last_Name : user.lastName
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
                        FirebaseConstant.name   : user.firstName + " " + user.lastName,
                        FirebaseConstant.email  : user.safeEmail
                    ]
                    userCollection.append(newElement)
                    
                    self.database.child(FirebaseConstant.users).setValue(userCollection) { (error, _) in
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
                            FirebaseConstant.name   : user.firstName + " " + user.lastName,
                            FirebaseConstant.email  : user.safeEmail
                        ]
                    ]
                    self.database.child(FirebaseConstant.users).setValue(newCollection) { (error, _) in
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
        database.child(FirebaseConstant.users).observeSingleEvent(of: .value) { (snapshot) in
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

//MARK: Sending messages / conversation

extension DatabaseManager {
/*

    "123456" => {
        "messages" : [
            {
                "id"        : String
                "type"      : text, photo, video
                "content"   : String
                "date"      : Date()
                "sender_emai" : String
                "isRead"    : String
            }
        ]
    }
     
    conversation => [
        [
            "conversation_id"   : "123456"
            "other_user_email"  :
            "latest_message"    : => {
                date    : Date()
                latest_message  : message
                is_read : true/false
            }
            "other_user_email"  :
            "other_user_email"  :
        ]
    ]
*/
    
    /// Creates a new conversation with target user email and first message sent
    public func createNewConversation(with otherUserEmail : String,
                                      firstMessage : Message,
                                      name : String,
                                      completion : @escaping (Bool) -> Void)
    {
        let safeEmail = DatabaseManager.shared.safeEmail(emailAddress: UDManager.sharedInstance.userEmail)
        let ref = database.child("\(safeEmail)")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard var userNode = snapshot.value as? [String : Any] else {
                completion(false)
                print("user Not found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatVC.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .custom(_):
                break
            }
            
            let conversationID = "conversation_\(firstMessage.messageId)"
            
            let newCoversationData : [String : Any] = [
                FirebaseConstant.conversation_id   : conversationID,
                FirebaseConstant.other_user_email  : otherUserEmail,
                FirebaseConstant.name              : name,
                FirebaseConstant.latest_message    :
                    [
                        FirebaseConstant.date      : dateString,
                        FirebaseConstant.message   : message,
                        FirebaseConstant.is_read   : false
                    ]
            ]
            
            if var conversations = userNode[FirebaseConstant.conversations] as? [[String : Any]] {
                //conversation array exist for current user
                //you should append
                conversations.append(newCoversationData)
                userNode[FirebaseConstant.conversations] = conversations
                
                ref.setValue(userNode) { (error, _) in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    self.finishCreatingConversation(name: name,
                                                    conversationID: conversationID,
                                                    firstMessage: firstMessage)
                    { (success) in
                        completion(true)
                    }
                }
            }
            else {
                //conversation array does NOT exist
                //create new conversation
                userNode[FirebaseConstant.conversations] = [
                    newCoversationData
                ]
                
                ref.setValue(userNode) { (error, _) in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    self.finishCreatingConversation(name: name,
                                                    conversationID: conversationID,
                                                    firstMessage: firstMessage) { (success) in
                        completion(true)
                    }
                }
            }
        }
        
    }
    
    private func finishCreatingConversation(name : String,
                                            conversationID : String,
                                            firstMessage : Message,
                                            completion : @escaping (Bool) -> Void)
    {
//        {
//            "id"        : String
//            "type"      : text, photo, video
//            "content"   : String
//            "date"      : Date()
//            "sender_emai" : String
//            "isRead"    : String
//        }
        
        var message = ""
        
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .custom(_):
            break
        }
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatVC.dateFormatter.string(from: messageDate)
        
        let currentUserEmail = DatabaseManager.shared.safeEmail(emailAddress: UDManager.sharedInstance.userEmail)
        
        let collectionMessage : [String : Any] = [
            FirebaseConstant.message_id         : firstMessage.messageId,
            FirebaseConstant.message_type       : firstMessage.kind.messageKindString,
            FirebaseConstant.message_content    : message,
            FirebaseConstant.message_date       : dateString,
            FirebaseConstant.message_sender_Email : currentUserEmail,
            FirebaseConstant.message_is_read    : false,
            FirebaseConstant.message_name       : name
        ]
        
        let value : [String : Any] = [
            "messages" : [
                collectionMessage
            ]
        ]
        
        database.child("\(conversationID)").setValue(value) { (error, _) in
            guard error == nil else {
                completion(false)
                return
            }
            
            completion(true)
        }
        
    }
    
    ///Fetches and returns all converstions for the user with passed in email
    public func getAllConversations(for email : String,
                                    completion : @escaping (Result<String, Error>) -> Void ) {
        
    }
    
    /// get all messages for a given conversation
    public func getAllMessagesForConversations(with id : String,
                                               completing : @escaping (Result<String, Error>) -> Void) {
        
    }
    
    ///Sends a message with target conversation and message
    public func sendMessage(to conversation : String, message : Message, completion : @escaping (Bool) -> Void) {
        
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
