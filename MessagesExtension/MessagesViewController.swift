//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by Developer on 5/29/17.
//  Copyright © 2017 JwitApps. All rights reserved.
//

import UIKit
import Messages
import SpriteKit

import Cartography

import iMessageTools
import JWSwiftTools

class MessagesViewController: MSMessagesAppViewController {
    
    var gameController: SpinnerViewController?
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        var session: SpinSession?
        
        if let message = conversation.selectedMessage  {
            session = SpinMessageReader(message: message)?.session
        }
        
        gameController = SpinnerViewController(previousSession: session, messageSender: self, orientationManager: self)
        
        present(gameController!)

    }
    
    func handleStarterEvent(message: MSMessage, conversation: MSConversation) {
        clearExistingControllers()
        
        let session = SpinMessageReader(message: message)?.session
        
        gameController = SpinnerViewController(previousSession: session, messageSender: self, orientationManager: self)
        
        present(gameController!)
    }
    
    func clearExistingControllers() {
        if let controller = gameController {
            throwAway(controller: controller)
        }
    }
    
    override func didSelect(_ message: MSMessage, conversation: MSConversation) {
        handleStarterEvent(message: message, conversation: conversation)
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }

}

extension MessagesViewController: MessageSender { }
