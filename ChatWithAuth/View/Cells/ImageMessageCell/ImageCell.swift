//
//  ImageCell.swift
//  ChatWithAuth
//
//  Created by Магжан Бекетов on 04.05.2021.
//

import UIKit
import Kingfisher
import Firebase

class ImageCell: UITableViewCell {

    static let identifier = String(describing: ImageCell.self)
    static let nib = UINib(nibName: identifier, bundle: nil)
    
    public var message : MessageEntity? {
        didSet{
            if let message = message{
                
                let url = URL(string: message.message)
                let processor = DownsamplingImageProcessor(size: messageImage.bounds.size)
                    |> RoundCornerImageProcessor(cornerRadius: 20)
                messageImage.kf.indicatorType = .activity
                messageImage.kf.setImage(
                    with: url,
                    placeholder: UIImage(named: "placeholderImage"),
                    options: [
                        .processor(processor),
                        .scaleFactor(UIScreen.main.scale),
                        .transition(.fade(3)),
                        .cacheOriginalImage
                    ])
                {
                    result in
                    switch result {
                    case .success(let value):
                        print("Task done for: \(value.source.url?.absoluteString ?? "")")
                    case .failure(let error):
                        print("Job failed: \(error.localizedDescription)")
                    }
                }
                if Auth.auth().currentUser?.email == message.sender{
                    containerView.backgroundColor = .systemGreen
                }else{
                    containerView.backgroundColor = .systemOrange
                }
                emailLabel.text = message.sender
            }
        }
    }
    
    @IBOutlet private weak var userImage: UIImageView!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var messageImage: UIImageView!
    @IBOutlet private weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        containerView.layer.cornerRadius = 4
        containerView.layer.masksToBounds = true
    }
}
