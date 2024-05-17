// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.



import PackageDescription
import Foundation

func loadPubspecVersion() -> String {
    let pubspecPath = "../firebase_core/pubspec.yaml"
    do {
        let yamlString = try String(contentsOfFile: pubspecPath, encoding: .utf8)
        if let versionLine = yamlString.split(separator: "\n").first(where: { $0.starts(with: "version:") }) {
            let version = versionLine.split(separator: ":")[1].trimmingCharacters(in: .whitespaces)
            return version.replacingOccurrences(of: "+", with: "-")
        }
    } catch {
        print("Error loading or parsing pubspec.yaml: \(error)")
    }
    return "1.0.0" // Default version if parsing fails
}

// Function to load Firebase SDK version from a Ruby script file
func loadFirebaseSDKVersion() -> String {
    let firebaseCoreScriptPath = "../firebase_core/ios/firebase_sdk_version.rb"
    do {
        let content = try String(contentsOfFile: firebaseCoreScriptPath, encoding: .utf8)
        let pattern = #"def firebase_sdk_version!\(\)\n\s+'([^']+)'\nend"#
        if let regex = try? NSRegularExpression(pattern: pattern, options: []),
           let match = regex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)) {
            if let versionRange = Range(match.range(at: 1), in: content) {
                return String(content[versionRange])
            }
        }
    } catch {
        print("Error loading or parsing firebase_sdk_version.rb: \(error)")
    }
    return "10.25.0" // Default version if parsing fails
}

let library_version: String = loadPubspecVersion()
let firebase_sdk_version_string: String = loadFirebaseSDKVersion()

guard let firebase_sdk_version = Version(firebase_sdk_version_string) else {
    fatalError("Invalid Firebase SDK version: \(firebase_sdk_version_string)")
}

let package = Package(
  name: "firebase_core",
  platforms: [
    .iOS("11.0"),
    .macOS("10.13"),
  ],
  products: [
    .library(name: "firebase-core", targets: ["firebase_core"]),
  ],
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: firebase_sdk_version)
  ],
  targets: [
    .target(
      name: "firebase_core",
      // Using FirebaseInstallations as FirebaseCore isn't a product and this is really small
      dependencies: [
        .product(name: "FirebaseInstallations", package: "firebase-ios-sdk")
                    ],
      resources: [
        .process("Resources"),
      ],
      cSettings: [
        .headerSearchPath("include/firebase_core"),
        .define("LIBRARY_VERSION", to: "\"\(library_version)\""),
        .define("LIBRARY_NAME", to: "\"flutter-fire-core\"")
      ]
    ),
  ]
)
