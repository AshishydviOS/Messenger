//
//  ChatVC.swift
//  Messenger
//
//  Created by Ashish Yadav on 16/11/20.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message : MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}

extension MessageKind {
    var messageKindString : String{
        switch self{
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedText"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .custom(_):
            return "custom"
        }
    }
}

struct Sender : SenderType {
    public var photoURL    : String
    public var senderId    : String
    public var displayName : String
}

class ChatVC: MessagesViewController {
    
    public static var dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    public let otherUserEmail : String
    public var isNewConversation = false
    
    private var messages = [Message]()
    
    private var selfSender : Sender {
        Sender(photoURL: "",
               senderId: UDManager.sharedInstance.userEmail,
               displayName: "Ashish Yadav")
    }
    
    init(with email : String) {
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource =  self
        messagesCollectionView.messagesLayoutDelegate =  self
        messagesCollectionView.messagesDisplayDelegate =  self
        messageInputBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
}

extension ChatVC : InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty  else {
            return
        }
        
        print("Sending : \(text)")
        
        //send Message
        if isNewConversation  {
            //create convo in database
            let message = Message(sender: selfSender ,
                                  messageId: createMessageID(),
                                  sentDate: Date(),
                                  kind: .text(text))
            DatabaseManager.shared.createNewConversation(with: otherUserEmail,
                                                         firstMessage: message,
                                                         name: self.title ?? "")
            { [weak self] (success) in
                
                if success {
                    print("Message Sent ")
                }
                else {
                    print("Failed to send")
                }
            }
        }
        else {
            //append to existing conversation
            
        }
    }
    
    private func createMessageID() -> String {
        
        let dateString = ChatVC.dateFormatter.string(from: Date())
        
        //date, otheruseremail, senderemail, randomInt
        let currentUserEmail = DatabaseManager.shared.safeEmail(emailAddress: UDManager.sharedInstance.userEmail)
        let newIdentifier = "\(otherUserEmail)_\(currentUserEmail)_\(dateString)"
        print("Create message id : \(newIdentifier)")
        return newIdentifier
    }
}

extension ChatVC : MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
}
