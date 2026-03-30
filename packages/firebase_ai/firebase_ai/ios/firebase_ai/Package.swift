// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import PackageDescription

let library_version = "3.10.0"

let package = Package(
  name: "firebase_ai",
  platforms: [
    .iOS("15.0"),
  ],
  products: [
    .library(name: "firebase-ai", targets: ["firebase_ai"]),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "firebase_ai",
      dependencies: [],
      resources: [
        .process("Resources"),
      ],
      cSettings: [
        .define("LIBRARY_VERSION", to: "\"\(library_version)\""),
        .define("LIBRARY_NAME", to: "\"flutter-fire-ai\""),
      ]
    ),
  ]
)
