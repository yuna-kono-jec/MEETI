//
//  Item.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import Foundation
import SwiftData

@Model
final class Participant {
    
    var number: Int
    var nickname: String
    var mbti: String
    var interests: [String]
    var message: String
    var photoData: Data?
    var createdAt: Date

    init(
        number: Int,
        nickname: String,
        mbti: String,
        interests: [String],
        message: String,
        photoData: Data? = nil,
        createdAt: Date = Date()
    ) {
        self.number = number
        self.nickname = nickname
        self.mbti = mbti
        self.interests = interests
        self.message = message
        self.photoData = photoData
        self.createdAt = createdAt
    }
}
