// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "MQTTBroker",
    dependencies: [
        .Package(url: "https://github.com/Zewo/TCP.git", majorVersion: 0, minor: 14)
    ]
)
