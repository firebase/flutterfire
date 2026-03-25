// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import Foundation
import PackageDescription

let firebase_sdk_version: Version = "12.9.0"

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
    .package(name: "firebase_core", path: "../firebase_core"),
  ],
  targets: [
    .target(
      name: "firebase_analytics",
      dependencies: [
        .product(name: analyticsProduct, package: "firebase-ios-sdk"),
        .product(name: "firebase-core", package: "firebase_core"),
      ],
      resources: [
        .process("Resources"),
      ]
    ),
  ]
)
