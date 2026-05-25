// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "DrawerKit",
    platforms: [.iOS(.v12)],
    products: [
        .library(name: "DrawerKit", targets: ["DrawerKit"]),
    ],
    targets: [
        .target(name: "DrawerKit"),
    ]
)
