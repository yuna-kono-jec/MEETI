// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "MEETILogic",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .target(
            name: "MEETILogic",
            path: "MEETI",
            exclude: [
                "Assets.xcassets",
                "MEETIApp.swift",
                "ContentView.swift",
                "StartView.swift",
                "ProfileInputView.swift",
                "MBTIQuestionView.swift",
                "MBTIResultView.swift",
                "MBTITypePickerView.swift",
                "BusinessCardView.swift",
                "QRCodeView.swift",
                "MatchingView.swift",
                "MatchResultView.swift",
                "PartnerCardView.swift"
            ],
            sources: [
                "Participant.swift",
                "MBTIQuestion.swift",
                "MBTICalculator.swift",
                "MBTITypeData.swift",
                "MBTIDiagnosisSession.swift",
                "InterestData.swift",
                "InterestSelection.swift",
                "CompatibilityCalculator.swift",
                "BestMatchCalculator.swift"
            ]
        ),
        .testTarget(
            name: "MEETILogicTests",
            dependencies: ["MEETILogic"],
            path: "MEETILogicTests"
        )
    ]
)
