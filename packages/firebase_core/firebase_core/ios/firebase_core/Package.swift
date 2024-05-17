// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "firebase_core",
  platforms: [
    .iOS("12.0"),
    .macOS("10.14"),
  ],
  products: [
    // If the plugin name contains "_", replace with "-" for the library name
    .library(name: "firebase-core", targets: ["firebase_core"]),
  ],
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.25.0"),
  ],
  targets: [
    .target(
      name: "firebase_core",
      // Using FirebaseInstallations as FirebaseCore isn't a product and this is a small product
      dependencies: [.product(name: "FirebaseInstallations", package: "firebase-ios-sdk")],
      resources: [
        .process("Resources"),
      ],
      cSettings: [
        .headerSearchPath("include/firebase_core"),
      ]
//            swiftSettings: [
//                            .define("LIBRARY_VERSION", to: "\"1.0.1\""),
//                            .define("LIBRARY_NAME", to: "\"flutter-fire-core\"")
//                        ]
    ),
  ]
)
