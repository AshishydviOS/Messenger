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
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender : SenderType {
    var photoURL    : String
    var senderId    : String
    var displayName : String
}

class ChatVC: MessagesViewController {
    
    public let otherUserEmail : String
    public var isNewConversation = false
    
    private var messages = [Message]()
    
    private var selfSender = Sender(photoURL: "",
                                    senderId: "1",
                                    displayName: "Ashish Yadav")
    
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
            
        }
        else {
            //append to existing conversation
            
        }
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
