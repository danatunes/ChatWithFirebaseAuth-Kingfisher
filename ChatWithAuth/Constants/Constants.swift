//
//  Constants.swift
//  ChatWithAuth
//
//  Created by Магжан Бекетов on 04.05.2021.
//

import Foundation
import Firebase

struct Constants {
    
    static let messagesDB = Database.database(url: "https://chatwithauth-1deeb-default-rtdb.europe-west1.firebasedatabase.app").reference().child("Messages")
    static let referenceForUploadImage = Storage.storage().reference().child("image_messages")
    
}
