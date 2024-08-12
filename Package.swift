// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "spm-talkplus-webrtc-framework",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "spm-talkplus-webrtc-framework",
            targets: ["spm-talkplus-webrtc-target",]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        //.package(url: "https://github.com/adxcorp/talkplus-ios-release.git", from: "0.6.3")
        .package(
            name: "spm-talkplus-framework",
            url: "https://github.com/adxcorp/talkplus-ios-release",
            from: "0.6.3"
        ),
        .package(url: "https://github.com/stasel/WebRTC.git", .exact("123.0.0"))
    ],
    targets: [
        .binaryTarget(
            name: "talkplus-webrtc-binary",
            path: "ios/TalkPlusWebRTC.xcframework"
        ),
        .target(
            name: "spm-talkplus-webrtc-target",
            dependencies: [
                .target(name: "talkplus-webrtc-binary"),
                .product(name: "spm-talkplus-framework", package: "spm-talkplus-framework"),
                .product(name: "WebRTC", package: "WebRTC"),
            ],
            path: ".",
            exclude: [
                "talkplus-ios-webrtc-swift/TalkPlusWebRTCSwift/AppDelegate.swift",
                "talkplus-ios-webrtc-swift/TalkPlusWebRTCSwift/SceneDelegate.swift",
                "talkplus-ios-webrtc-swift/TalkPlusWebRTCSwift/CXCallManager.swift",
                "talkplus-ios-webrtc-swift/TalkPlusWebRTCSwift/VideoCallViewController.swift",
                "talkplus-ios-webrtc-swift/TalkPlusWebRTCSwift/Info.plist",
                "talkplus-ios-webrtc-swift/TalkPlusWebRTCSwift/TalkPlusWebRTCSwift.entitlements",
            ]
        ),
    ]
)