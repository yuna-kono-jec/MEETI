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
                "CameraPicker.swift",
                "ParticipantSyncService.swift",
                "PhotoUploadService.swift",
                "SupabaseService.swift",
                "OperatorLoginView.swift",
                "BusinessCardView.swift",
                "QRCodeView.swift",
                "MatchingView.swift",
                "MatchResultView.swift",
                "PartnerCardView.swift",
                "CardURLBuilder.swift",
                "MEETIStyle.swift",
                "QRCodeGenerator.swift",
                "WebCard"
            ],
            sources: [
                "Participant.swift",
                "PhotoThumbnail.swift", // 表示用画像の向き・縮小・再利用を検証します。
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
