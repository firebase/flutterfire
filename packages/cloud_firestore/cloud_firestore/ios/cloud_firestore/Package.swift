// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import Foundation
import PackageDescription


enum ConfigurationError: Error {
  case fileNotFound(String)
  case parsingError(String)
  case invalidFormat(String)
}

let iosRootDirectory = String(URL(string: #file)!.deletingLastPathComponent().absoluteString
  .dropLast())

func loadPubspecVersion() throws -> (libraryVersion: String, iosSdkVersion: String) {
  let pubspecPath = NSString.path(withComponents: [iosRootDirectory, "..", "..", "pubspec.yaml"])
  do {
    let yamlString = try String(contentsOfFile: pubspecPath, encoding: .utf8)
    let lines = yamlString.split(separator: "\n")

    guard let versionLine = lines.first(where: { $0.starts(with: "version:") }) else {
      throw ConfigurationError.invalidFormat("No version line found in pubspec.yaml")
    }
    let libraryVersion = versionLine.split(separator: ":")[1].trimmingCharacters(in: .whitespaces)
      .replacingOccurrences(of: "+", with: "-")

    // Adjusted to find ios_sdk under the firebase key
    guard let firebaseIndex = lines.firstIndex(where: { $0.starts(with: "firebase:") }) else {
      throw ConfigurationError.invalidFormat("No firebase section found in pubspec.yaml")
    }
    let iosSdkLine = lines.dropFirst(firebaseIndex + 1).first(where: { $0.trimmingCharacters(in: .whitespaces).starts(with: "ios_sdk:") })
    guard let iosSdkLine = iosSdkLine else {
      throw ConfigurationError.invalidFormat("No ios_sdk line found in pubspec.yaml")
    }
    let iosSdkVersion = iosSdkLine.split(separator: ":")[1].trimmingCharacters(in: .whitespaces)

    return (libraryVersion, iosSdkVersion)
  } catch {
    throw ConfigurationError.fileNotFound("Error loading or parsing pubspec.yaml: \(error)")
  }
}

let library_version: String
let firebase_sdk_version_string: String

do {
  let versions = try loadPubspecVersion()
  library_version = versions.libraryVersion
  firebase_sdk_version_string = versions.iosSdkVersion
} catch {
  fatalError("Failed to load configuration: \(error)")
}

guard let firebase_sdk_version = Version(firebase_sdk_version_string) else {
  fatalError("Invalid Firebase SDK version: \(firebase_sdk_version_string)")
}

let package = Package(
  name: "cloud_firestore",
  platforms: [
    .iOS("13.0"),
  ],
  products: [
    .library(name: "cloud-firestore", targets: ["cloud_firestore"]),
  ],
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: firebase_sdk_version),
    // This works
    // .package(name:"flutterfire", path: "../../../../.."),
    // TODO - this needs a version instead
    // This isn't working
    .package(url:"https://github.com/russellwheatley/test-flutterfire", exact: "0.0.19"),
  ],
  targets: [
    .target(
      name: "cloud_firestore",
      dependencies: [
        .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
        // Wrapper dependency
        .product(name: "firebase-core-wrapper", package: "test-flutterfire")
      ],
      resources: [
        .process("Resources"),
      ],
      cSettings: [
        .headerSearchPath("include/cloud_firestore/Private"),
        .headerSearchPath("include/cloud_firestore/Public"),
        .define("LIBRARY_VERSION", to: "\"\(library_version)\""),
        .define("LIBRARY_NAME", to: "\"flutter-fire-fst\""),
      ]
    ),
  ]
)
