// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "SDRemoteImageView",
    platforms: [.iOS(.v8)],
    products: [
        .library(name: "SDRemoteImageView", targets: ["SDRemoteImageView"]),
    ],
    targets: [
        .target(
            name: "SDRemoteImageView",
            path: "SDRemoteImageView/Classes"),
        .testTarget(
            name: "SDRemoteImageViewTests",
            dependencies: ["SDRemoteImageView"],
            path: "Example/Tests")
    ]
)
