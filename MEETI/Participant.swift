//
//  Item.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import Foundation
import SwiftData

// プロフィールとマッチングで使う選択肢です。
let genderOptions = ["男性", "女性"]
let matchingGenderOptions = ["どちらでも", "男性", "女性"]
let ageGroupOptions = [
    "0〜9歳", "10〜19歳", "20〜29歳", "30〜39歳", "40〜49歳",
    "50〜59歳", "60〜69歳", "70〜79歳", "80〜89歳", "90〜99歳",
    "100歳以上"
]
let matchingAgeGroupOptions = ["指定しない"] + ageGroupOptions

@Model
final class Participant {
    
    var number: Int
    var nickname: String
    var mbti: String
    var interests: [String]
    var message: String
    // 古い保存データは「未回答」としてそのまま使えます。
    var gender: String = "未回答"
    var ageGroup: String = "未回答"
    var photoData: Data?
    var createdAt: Date

    init(
        number: Int,
        nickname: String,
        mbti: String,
        interests: [String],
        message: String,
        gender: String = "未回答",
        ageGroup: String = "未回答",
        photoData: Data? = nil,
        createdAt: Date = Date()
    ) {
        self.number = number
        self.nickname = nickname
        self.mbti = mbti
        self.interests = interests
        self.message = message
        self.gender = gender
        self.ageGroup = ageGroup
        self.photoData = photoData
        self.createdAt = createdAt
    }
}
