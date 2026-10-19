//
//  CardURLBuilder.swift
//  MEETI
//
//  Created by cmStudent on 2026/10/04.
//

import Foundation

struct CardURLBuilder {
    static func makeURL(from participant: Participant) -> URL? {
        var components = URLComponents(
            string: "https://yuna-kono-jec.github.io/MEETI/MEETI/WebCard/"
        )

        components?.queryItems = [
            URLQueryItem(
                name: "number",
                value: String(participant.number)
            ),
            URLQueryItem(
                name: "name",
                value: participant.nickname
            ),
            URLQueryItem(
                name: "mbti",
                value: participant.mbti
            ),
            URLQueryItem(
                name: "interests",
                value: participant.interests.joined(separator: ",")
            ),
            URLQueryItem(
                name: "message",
                value: participant.message
            )
        ]

        if let token = participant.webPhotoToken,
           token.count == 64,
           token.allSatisfy({
               "0123456789abcdef".contains($0)
           }) {
            components?.fragment = "photoToken=\(token)"
        }

        return components?.url
    }
}
