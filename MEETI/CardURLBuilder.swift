//
//  CardURLBuilder.swift
//  MEETI
//
//  Created by cmStudent on 2026/10/04.
//

import Foundation

struct CardURLBuilder {

    // URLを作る処理
    // SampleParticipantの情報を受け取って、URLを作る関数
    static func makeURL(from participant: Participant) -> URL? {

        // Web名刺のURLを指定する
        var components = URLComponents(
            string: "https://yuna-kono-jec.github.io/MEETI/MEETI/WebCard/"
        )

        components?.queryItems = [
            URLQueryItem(name: "number", value: String(participant.number)),
            URLQueryItem(name: "name", value: participant.nickname),
            URLQueryItem(name: "mbti", value: participant.mbti),
            URLQueryItem(name: "interests", value: participant.interests.joined(separator: ",")),
            URLQueryItem(name: "message", value: participant.message)
        ]

        return components?.url
    }
}

