//
//  DatabaseManager.swift
//  ChatWithAuth
//
//  Created by Магжан Бекетов on 03.05.2021.
//

import Foundation
import Firebase

typealias MessageEntityHandler = (Result<MessageEntity,FetchingData>) -> Void
typealias ForSendMessageToFirebase = (Result<String,SendMessageErrors>) -> Void
typealias ForRemoveMessage = (Result<String, Error>) -> Void
typealias ForUploadToStorage = (Result<URL , Error>) -> Void

public final class DatabaseManager {
    
    //var clouser : ((String) -> String)?
    
    static let shared = DatabaseManager()
    
    func sendMessagesToFirebase(message : String ,completion : @escaping ForSendMessageToFirebase){
        guard let email = Auth.auth().currentUser?.email else {
            completion(.failure(.emailIsNil))
            return
        }
        
        let messageID = Date().asUUID
        
        let messagesDict = ["sender": email, "message": message , "messageID": messageID]
        
        
        Constants.messagesDB.child(messageID).setValue(messagesDict) { (error, reference) in
            if error != nil {
                completion(.failure(.failedToSendMessage))
            }else{
                completion(.success("Successfully!"))
            }
        }
        
    }
    
    func fetchMessagesFromFirebase(completion : @escaping MessageEntityHandler) {
        Constants.messagesDB.observe(.childAdded) {  (snapshot) in
            if let values = snapshot.value as? [String:String]{
                guard let message = values["message"] else {
                    //completion(.failure("message is nil" as! Error))
                    completion(.failure(.messageIsNil))
                    return
                }
                guard let sender = values["sender"] else {
                    completion(.failure(.senderIsNil))
                    return
                }
                guard let messageID = values["messageID"] else {
                    completion(.failure(.messageIdIsNil))
                    return
                }
                completion(.success(MessageEntity(message: message, sender: sender, messageID: messageID)))
            }
        }
    }
    
    func uploadImageToStorage(photo : UIImage , completion : @escaping ForUploadToStorage){
        
        let uuid = UUID().uuidString
        let id = "\(Auth.auth().currentUser?.email ?? "")_\(uuid)"
        let referenceForUploadImage = Constants.referenceForUploadImage.child(id)
        
        
        guard let imageData = photo.jpegData(compressionQuality: 0.4) else {
            return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        referenceForUploadImage.putData(imageData, metadata: metadata) { (metadata, error) in
            guard let _ = metadata else{
                completion(.failure(error!))
                return
            }
            referenceForUploadImage.downloadURL { (url, error) in
                guard let url = url else{
                    completion(.failure(error!))
                    return
                }
                completion(.success(url))
            }
        }
    }

    func removeMessage(messageID : String , completion : @escaping ForRemoveMessage) {
        let reference = Constants.messagesDB.child(messageID)
        reference.removeValue(){ error,_ in
            if error != nil {
                completion(.failure(error!))
            }
            completion(.success("... Succesfully removed \(messageID)"))
        }
    }
    
    func removeImageFromStorage(message : MessageEntity){
        
        
        Constants.referenceForUploadImage.child("codebuster@bk.ru_EBF11C51-E149-479E-9945-2B552A04A374").delete { [weak self] (error) in
            if error != nil {
                print(".... \(String(describing: error))")
            }else{
                self?.removeMessage(messageID: message.messageID) { (result) in
                    switch result {
                    case .success(let message):
                        print("... \(message)")
                    case .failure(let error):
                        print(".... \(error)")
                    }
                }
            }
        }
    }
}

extension Date {
    
    var asUUID: String {
        let asInteger = Int(self.timeIntervalSince1970)
          return String(asInteger)
       }
    
}
