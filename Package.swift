// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "MQTTBroker",
    dependencies: [
        .Package(url: "https://github.com/Zewo/Zewo.git", majorVersion: 0)
    ]
)
