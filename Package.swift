// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Frenzy",
    products: [.executable(name: "Frenzy",  targets: ["Frenzy"])],
    dependencies: [
        .package(url: "https://github.com/Zewo/Zewo.git", .branch("master"))
    ],
    targets: [
        .target(name: "Frenzy", dependencies: ["Zewo"])
    ]
)
