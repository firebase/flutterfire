// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import Foundation
import PackageDescription

// Using this as a wrapper around firebase core, this allows retrieval of it via remote package
// whilst also preserving firebase core's Package.swift file needed by Flutter
let package = Package(
  name: "remote_firebase_core",
  platforms: [
    .iOS("13.0"),
  ],
  products: [
    .library(name: "firebase-core-target", targets: ["firebase_core_target"]),
  ],
  targets: [
    .target(
      name: "firebase_core_target",
      dependencies:[
        .target(name: "firebase_core")
      ],
      path: "Sources/firebase_core_target"
    ),
    .target(
      name: "firebase_core",
      path: "packages/firebase_core/firebase_core/ios/firebase_core",
      exclude: ["Package.swift"],
      publicHeadersPath: "Sources/firebase_core/include"
    ),
  ]
)
