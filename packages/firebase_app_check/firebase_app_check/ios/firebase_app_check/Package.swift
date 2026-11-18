// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import Foundation
import PackageDescription

let firebaseSdkVersion: Version = "13.2.0"

/// Set FIREBASE_APP_CHECK_WITHOUT_RECAPTCHA=true to leave out the reCAPTCHA
/// Enterprise SDK if the app does not use AppleReCaptchaProvider. Any other
/// value keeps the SDK.
/// e.g. FIREBASE_APP_CHECK_WITHOUT_RECAPTCHA=true flutter build ios
let withoutRecaptcha =
  ProcessInfo.processInfo.environment["FIREBASE_APP_CHECK_WITHOUT_RECAPTCHA"] == "true"

var recaptchaPackages: [Package.Dependency] = []
var recaptchaProducts: [Target.Dependency] = []
if !withoutRecaptcha {
  recaptchaPackages.append(
    .package(
      url: "https://github.com/GoogleCloudPlatform/recaptcha-enterprise-mobile-sdk.git",
      from: "18.0.0"
    )
  )
  recaptchaProducts.append(
    .product(name: "RecaptchaEnterprise", package: "recaptcha-enterprise-mobile-sdk")
  )
}

let package = Package(
  name: "firebase_app_check",
  platforms: [
    .iOS("15.0")
  ],
  products: [
    .library(name: "firebase-app-check", targets: ["firebase_app_check"])
  ],
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", exact: firebaseSdkVersion),
    .package(name: "firebase_core", path: "../firebase_core"),
    .package(name: "FlutterFramework", path: "../FlutterFramework"),
  ] + recaptchaPackages,
  targets: [
    .target(
      name: "firebase_app_check",
      dependencies: [
        .product(name: "FirebaseAppCheck", package: "firebase-ios-sdk"),
        .product(name: "firebase-core", package: "firebase_core"),
        .product(name: "FlutterFramework", package: "FlutterFramework"),
      ] + recaptchaProducts,
      resources: [
        .process("Resources")
      ]
    )
  ]
)
