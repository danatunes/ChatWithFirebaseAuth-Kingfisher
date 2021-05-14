//
//  MessageCell.swift
//  ChatWithAuth
//
//  Created by Магжан Бекетов on 29.04.2021.
//

import UIKit
import Firebase

class MessageCell: UITableViewCell {

    public static let identifier = String(describing: MessageCell.self)
    public static let nib = UINib(nibName: identifier, bundle: nil)
    
    @IBOutlet private weak var senderLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var containerView: UIView!
    
    public var message : MessageEntity? {
        
        didSet{
            if let message = message {
                senderLabel.text = message.sender
                messageLabel.text = message.message
                
                if Auth.auth().currentUser?.email == message.sender{
                    containerView.backgroundColor = .systemGreen
                }else{
                    containerView.backgroundColor = .systemOrange
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        containerView.layer.cornerRadius = 4
        containerView.layer.masksToBounds = true
    }
}
