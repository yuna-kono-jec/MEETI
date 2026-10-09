//
//  SampleParticipant.swift
//  MEETI
//
//  Created by cmStudent on 2026/10/04.
//

import Foundation

struct SampleParticipant {
    let number: Int
    let name: String
    let mbti: String
    let interests: [String]
    let message: String
    let photoData: Data?
}

let sampleParticipant = SampleParticipant(
    number: 37,
    name: "YUNA",
    mbti: "ENFJ",
    interests: ["音楽", "カフェ", "犬"],
    message: "話しかけてください！",
    photoData: nil
)

