// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import PackageDescription

let libraryVersionString = "4.13.0"
let firebaseSdkVersion: Version = "12.18.0"

let package = Package(
  name: "firebase_core",
  platforms: [
    .iOS("15.0")
  ],
  products: [
    .library(name: "firebase-core", targets: ["firebase_core", "firebase_core_objc"])
  ],
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", exact: firebaseSdkVersion),
    .package(name: "FlutterFramework", path: "../FlutterFramework"),
  ],
  targets: [
    // SPM does not allow mixing Swift and ObjC in a single target.
    // The ObjC target keeps FLTFirebasePlugin / Registry as the public
    // header surface other plugins `#import <firebase_core/...>`.
    .target(
      name: "firebase_core_objc",
      dependencies: [
        .product(name: "FirebaseInstallations", package: "firebase-ios-sdk"),
        .product(name: "FlutterFramework", package: "FlutterFramework"),
      ],
      path: "Sources/firebase_core_objc",
      publicHeadersPath: "include",
      cSettings: [
        .headerSearchPath("include/firebase_core"),
        .headerSearchPath("include"),
        .define("LIBRARY_VERSION", to: "\"\(libraryVersionString)\""),
        .define("LIBRARY_NAME", to: "\"flutter-fire-core\""),
      ]
    ),
    .target(
      name: "firebase_core",
      dependencies: [
        "firebase_core_objc",
        .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
        .product(name: "FirebaseInstallations", package: "firebase-ios-sdk"),
        .product(name: "FlutterFramework", package: "FlutterFramework"),
      ],
      path: "Sources/firebase_core",
      resources: [
        .process("Resources")
      ]
    ),
  ]
)
