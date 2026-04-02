// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import PackageDescription

let package = Package(
  name: "firebase_ai",
  platforms: [
    .macOS("10.15"),
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
      ]
    ),
  ]
)
