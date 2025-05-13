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

let firebaseCoreDirectory = String(URL(string: #file)!.deletingLastPathComponent().absoluteString
  .dropLast())

func loadPubspecVersion() throws -> String {
  let pubspecPath = NSString.path(withComponents: [
    firebaseCoreDirectory,
    "..",
    "..",
    "pubspec.yaml",
  ])
  do {
    let yamlString = try String(contentsOfFile: pubspecPath, encoding: .utf8)
    if let versionLine = yamlString.split(separator: "\n")
      .first(where: { $0.starts(with: "version:") }) {
      let version = versionLine.split(separator: ":")[1].trimmingCharacters(in: .whitespaces)
      return version.replacingOccurrences(of: "+", with: "-")
    } else {
      throw ConfigurationError.invalidFormat("No version line found in pubspec.yaml")
    }
  } catch {
    throw ConfigurationError.fileNotFound("Error loading or parsing pubspec.yaml: \(error)")
  }
}

func loadFirebaseSDKVersion() throws -> String {
  let firebaseCoreScriptPath = NSString.path(withComponents: [
    firebaseCoreDirectory,
    "..",
    "..",
    "ios",
    "firebase_sdk_version.rb",
  ])
  do {
    let content = try String(contentsOfFile: firebaseCoreScriptPath, encoding: .utf8)
    let pattern = #"def firebase_sdk_version!\(\)\n\s+'([^']+)'\nend"#
    if let regex = try? NSRegularExpression(pattern: pattern, options: []),
       let match = regex.firstMatch(
         in: content,
         range: NSRange(content.startIndex..., in: content)
       ) {
      if let versionRange = Range(match.range(at: 1), in: content) {
        return String(content[versionRange])
      } else {
        throw ConfigurationError.invalidFormat("Invalid format in firebase_sdk_version.rb")
      }
    } else {
      throw ConfigurationError.parsingError("No match found in firebase_sdk_version.rb")
    }
  } catch {
    throw ConfigurationError
      .fileNotFound("Error loading or parsing firebase_sdk_version.rb: \(error)")
  }
}

let library_version_string: String
let firebase_sdk_version_string: String
let shared_spm_tag = "-firebase-core-swift"

do {
  library_version_string = try loadPubspecVersion()
  firebase_sdk_version_string = try loadFirebaseSDKVersion()
} catch {
  fatalError("Failed to load configuration: \(error)")
}

guard let firebase_sdk_version = Version(firebase_sdk_version_string) else {
  fatalError("Invalid Firebase SDK version: \(firebase_sdk_version_string)")
}

// TODO: - we can try using existing firebase_core tag once flutterfire/Package.swift is part of release cycle
// but I don't think it'll work as Swift versioning requires version-[tag name]
guard let shared_spm_version = Version("\(library_version_string)\(shared_spm_tag)") else {
  fatalError("Invalid firebase_core version: \(library_version_string)\(shared_spm_tag)")
}

let package = Package(
  name: "firebase_core",
  platforms: [
    .macOS("10.15"),
  ],
  products: [
    .library(name: "firebase-core", targets: ["firebase_core"]),
  ],
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: firebase_sdk_version),
    .package(url: "https://github.com/firebase/flutterfire", exact: shared_spm_version),
  ],
  targets: [
    .target(
      name: "firebase_core",
      dependencies: [
        // No product for firebase-core so we pull in the smallest one
        .product(name: "FirebaseInstallations", package: "firebase-ios-sdk"),
        .product(name: "firebase-core-shared", package: "flutterfire"),
      ],
      exclude: [
        // These are now pulled in as a remote dependency from FlutterFire repo
        "FLTFirebaseCorePlugin.m",
        "FLTFirebasePlugin.m",
        "FLTFirebasePluginRegistry.m",
        "messages.g.m",
        "include/firebase_core/FLTFirebaseCorePlugin.h",
        "include/firebase_core/messages.g.h",
        "include/firebase_core/FLTFirebasePlugin.h",
        "include/firebase_core/FLTFirebasePluginRegistry.h",
      ],
      resources: [
        .process("Resources"),
      ],
      cSettings: [
        .headerSearchPath("include/firebase_core"),
        .define("LIBRARY_VERSION", to: "\"\(library_version_string)\""),
        .define("LIBRARY_NAME", to: "\"flutter-fire-core\""),
      ]
    ),
  ]
)
