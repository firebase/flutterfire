// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import PackageDescription

let firebase_sdk_version: Version = "12.9.0"

let package = Package(
  name: "firebase_ml_model_downloader",
  platforms: [
    .macOS("10.15"),
  ],
  products: [
    .library(name: "firebase-ml-model-downloader", targets: ["firebase_ml_model_downloader"]),
  ],
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: firebase_sdk_version),
    .package(name: "firebase_core", path: "../firebase_core"),
  ],
  targets: [
    .target(
      name: "firebase_ml_model_downloader",
      dependencies: [
        .product(name: "FirebaseMLModelDownloader", package: "firebase-ios-sdk"),
        .product(name: "firebase-core", package: "firebase_core"),
      ],
      resources: [
        .process("Resources"),
      ]
    ),
  ]
)
