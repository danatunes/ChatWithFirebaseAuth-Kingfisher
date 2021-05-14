//
//  FirebaseErrorsEnum.swift
//  ChatWithAuth
//
//  Created by Магжан Бекетов on 05.05.2021.
//

import Foundation

enum SendMessageErrors : Error {
    case emailIsNil
    case failedToSendMessage
}

enum FetchingData : Error {
    case messageIsNil
    case senderIsNil
    case messageIdIsNil
}
