//
//  ChatVC.swift
//  Messenger
//
//  Created by Ashish Yadav on 16/11/20.
//

import UIKit
import MessageKit


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
        
        messages.append(Message(sender: selfSender,
                                messageId: "1",
                                sentDate: Date(),
                                kind: .text("Hello World Message")))
        
        messages.append(Message(sender: selfSender,
                                messageId: "2",
                                sentDate: Date(),
                                kind: .text("Hello World Message. Hello World Message. Hello World Message. Hello World Message. Hello World Message.")))
        
        
        messagesCollectionView.messagesDataSource =  self
        messagesCollectionView.messagesLayoutDelegate =  self
        messagesCollectionView.messagesDisplayDelegate =  self
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
