// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Swift Package Manager pin for firebase-ios-sdk.
///
/// This may be newer than the CocoaPods pin in
/// `packages/firebase_core/firebase_core/ios/firebase_sdk_version.rb`.
/// Firebase stops publishing new Apple SDK versions to CocoaPods in
/// October 2026. Podspecs must keep using the last version that was
/// published as a pod.
const String firebaseSpmSdkVersion = '13.0.0';
