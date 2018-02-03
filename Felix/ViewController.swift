//
//  ViewController.swift
//  Felix
//
//  Created by Kevin Tan on 2/3/18.
//  Copyright © 2018 Felix Inc. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ChatBotViewController: JSQMessagesViewController {

    // Properties
    
    private var m_messages = [JSQMessage]()
    
    private lazy var m_outgoingBubble = setupOutgoingBubble()
    private lazy var m_incomingBubble = setupIncomingBubble()
    
    // Methods
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.senderDisplayName = "Helen"
        self.senderId = "blah"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.senderDisplayName = "Helen"
        self.senderId = "blah"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Helper Functions
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.blue)
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.lightGray)
    }
    
    // JSQMessages
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let newMessage = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)!
        m_messages.append(newMessage)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.collectionView.reloadData()
        finishSendingMessage()
    }

    // Collection View
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return m_messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return m_messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {

        let message = m_messages[indexPath.row]
        
        if message.senderId == senderId {
            return m_outgoingBubble
        } else {
            return m_incomingBubble
        }
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
}

