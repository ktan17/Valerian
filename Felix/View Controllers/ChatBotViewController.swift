//
//  ViewController.swift
//  Felix
//
//  Created by Kevin Tan on 2/3/18.
//  Copyright © 2018 Felix Inc. All rights reserved.
//

import UIKit
import JSQMessagesViewController

enum FelixEmotion: Int {
    case CONCERNED = 0
    case FRUSTRATED
    case MAD
    case CRY
    case SAD
    case JOY
    case HAPPY
    case PROUD
}

enum State: String {
    case FREE_PROMPT = "free_prompt"
    case ID_NEG_THOUGHT = "id_neg_thought"
    case CHALLENGE = "challenge_neg_thought"
    case EXERCISE = "exercise_alt_thought"
    case START = "start"
    case HELP = "help"
}

class ChatBotViewController: JSQMessagesViewController {

    // Properties
    
    private var m_messages = [JSQMessage]()
    private var m_queuedMessages = [JSQMessage]()
    
    private var m_currentState: State = .START
    
    private lazy var m_outgoingBubble = setupOutgoingBubble()
    private lazy var m_incomingBubble = setupIncomingBubble()
    
    private var m_httpDelegate: FelixHTTPDelegate!
    
    // Methods
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.senderDisplayName = globalName
        self.senderId = "blah"
        
        m_httpDelegate = HTTPDelegate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.senderDisplayName = "Helen"
        self.senderId = "blah"
        
        m_httpDelegate = HTTPDelegate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = .zero
        self.inputToolbar.contentView.leftBarButtonItem = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = .clear
        collectionView.backgroundColor = .clear
        
        let backgroundImageView = UIImageView(frame: self.view.bounds)
        //backgroundImageView.frame.size = self.collectionView.frame.size
        //backgroundImageView.center = self.collectionView.center
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.image = UIImage(named: "WelcomeBG")
        
        view.addSubview(backgroundImageView)
        view.sendSubview(toBack: backgroundImageView)
    }
    
    @objc func dequeueMessages(_ sender: Timer!) {
        
        if !m_queuedMessages.isEmpty {
            m_messages.append(m_queuedMessages[m_queuedMessages.count-1])
            self.collectionView.reloadData()
            self.finishReceivingMessage()
            m_queuedMessages.removeLast()
        }
        
        if m_queuedMessages.isEmpty {
            sender.invalidate()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Helper Functions
    
    private func isLastUserSentMessage(_ message: JSQMessage) -> Bool {
        let userMessages = m_messages.filter { $0.senderId == self.senderId }
        return userMessages.count > 0 && message.isEqual(userMessages.last!)
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor(red: 0.0313, green: 0.4980, blue: 1, alpha: 1))
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor(white: 0.9, alpha: 1))
    }
    
    // JSQMessages
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let newMessage = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)!
        m_messages.append(newMessage)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.collectionView.reloadData()
        finishSendingMessage()
        
        m_httpDelegate.post(url: "http://localhost:8080/", message: text, state: m_currentState) { (response) in
            
            print(response)
            
            let sortedKeys = Array(response.keys).sorted(by: >)
            for key in sortedKeys {
                
                let newMessage = JSQMessage(senderId: "bot", senderDisplayName: "bot", date: Date(timeIntervalSinceNow: 0), text: response[key] as! String)!
                self.m_queuedMessages.append(newMessage)
                
            }
            
            Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.dequeueMessages), userInfo: nil, repeats: true)
            
        }
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
        
        let message = m_messages[indexPath.row]
        if message.senderId == senderId {
            return nil
        }
        
        return nil
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
            as! JSQMessagesCollectionViewCell
        
        let message = m_messages[indexPath.row]
        
        if message.senderId != self.senderId {
            cell.textView!.textColor = UIColor.black
        }
        
        return cell
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        // This function is used to specify the text that should go in the topLabel
        // of a message.
        
        let message = m_messages[indexPath.item]
        
        if indexPath.item == 0 {
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            
            if Calendar.current.isDateInToday(message.date) {
                return NSAttributedString(string: "Today")
            }
                
            else if Calendar.current.isDateInYesterday(message.date) {
                return NSAttributedString(string: "Yesterday")
            }
                
            else {
                
                formatter.dateFormat = "MMMM d, yyyy"
                let readableDate = formatter.string(from: message.date)
                
                return NSAttributedString(string: readableDate)
                
            }
            
        }
            
        else {
            
            let previousMessage = m_messages[indexPath.item-1]
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            
            if formatter.string(from: previousMessage.date) != formatter.string(from: message.date) {
                
                if Calendar.current.isDateInToday(message.date) {
                    return NSAttributedString(string: "Today")
                }
                    
                else if Calendar.current.isDateInYesterday(message.date) {
                    return NSAttributedString(string: "Yesterday")
                }
                    
                else {
                    
                    formatter.dateFormat = "MMMM d, yyyy"
                    let readableDate = formatter.string(from: message.date)
                    
                    return NSAttributedString(string: readableDate)
                    
                }
                
            }
            
        }
        
        return NSAttributedString(string: "")
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        // This function is used to set the height of the topLabel for messages. We'll
        // use this topLabel to display dates.
        
        let titleHeight: CGFloat = 24
        
        let message = m_messages[indexPath.item]
        
        if indexPath.item == 0 {
            return titleHeight
        }
            
        else {
            
            let previousMessage = m_messages[indexPath.item-1]
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            
            if formatter.string(from: previousMessage.date) != formatter.string(from: message.date) {
                // Dates are different.
                return titleHeight
            }
                
            else if message.senderId == previousMessage.senderId && message.date.timeIntervalSince(previousMessage.date) >= 900 {
                // 15 minute gap exists between two message sent by same person (15m == 900s).
                return 16.0
            }
            
        }
        
        return 0.0
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        // This function is used to specify the text that should go in the bottomLabel
        // of a message.
        
        let message = m_messages[indexPath.item]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        
        if isLastUserSentMessage(message) {
            
            var text = "Delivered " + formatter.string(from: message.date)
            if message.senderId == self.senderId {
                text += "   "
            }
                
            else {
                text = "   " + text
            }
            
            return NSAttributedString(string: text)
            
        }
        
        var text = formatter.string(from: message.date)
        if message.senderId == self.senderId {
            text += "   "
        }
            
        else {
            text = "  " + text
        }
        
        if indexPath.item == m_messages.count-1 {
            return NSAttributedString(string: text)
        }
        
        let nextMessage = m_messages[indexPath.item+1]
        
        let checkerFormatter = DateFormatter()
        checkerFormatter.dateFormat = "ddMMyyyyh:mm a"
        
        if checkerFormatter.string(from: message.date) == checkerFormatter.string(from: nextMessage.date) {
            return NSAttributedString(string: "")
        }
        
        return NSAttributedString(string: text)
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        // This function is used to set the height of the bottomLabel for messages. We'll
        // use this bottomLabel to display timestamps.
        
        let titleHeight: CGFloat = 20.0
        
        let message = m_messages[indexPath.item]
        
        if isLastUserSentMessage(message) {
            return titleHeight
        }
        
        if indexPath.item == m_messages.count-1 {
            // We know this message is not the last user sent message and we need to check
            // m_messages[indexPath.item+1], so this needs to be here so that we don't
            // access an out of bounds array position.
            return 20.0
        }
        
        let nextMessage = m_messages[indexPath.item+1]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyyh:mm a"
        
        if formatter.string(from: message.date) == formatter.string(from: nextMessage.date) {
            return 0.0
        }
        
        return titleHeight
        
    }
    
}

