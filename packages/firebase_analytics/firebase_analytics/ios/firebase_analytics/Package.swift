// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import Foundation
import PackageDescription

let firebase_sdk_version = Version("12.9.0")!
let shared_spm_version = Version("4.5.0-firebase-core-swift")!

// Set FIREBASE_ANALYTICS_WITHOUT_ADID=true to use FirebaseAnalyticsWithoutAdIdSupport
// e.g. FIREBASE_ANALYTICS_WITHOUT_ADID=true flutter build ios
let useWithoutAdId = ProcessInfo.processInfo.environment["FIREBASE_ANALYTICS_WITHOUT_ADID"] != nil
let analyticsProduct = useWithoutAdId ? "FirebaseAnalyticsWithoutAdIdSupport" : "FirebaseAnalytics"

let package = Package(
  name: "firebase_analytics",
  platforms: [
    .iOS("15.0"),
  ],
  products: [
    .library(name: "firebase-analytics", targets: ["firebase_analytics"]),
  ],
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: firebase_sdk_version),
    .package(url: "https://github.com/firebase/flutterfire", exact: shared_spm_version),
  ],
  targets: [
    .target(
      name: "firebase_analytics",
      dependencies: [
        .product(name: analyticsProduct, package: "firebase-ios-sdk"),
        // Wrapper dependency
        .product(name: "firebase-core-shared", package: "flutterfire"),
      ],
      resources: [
        .process("Resources"),
      ]
    ),
  ]
)
