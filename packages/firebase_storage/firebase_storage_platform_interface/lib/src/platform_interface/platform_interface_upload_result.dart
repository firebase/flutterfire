// Copyright 2022 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../../firebase_storage_platform_interface.dart';

/// The class for an upload result.
class UploadResultPlatform extends PlatformInterface {
  // ignore: public_member_api_docs
  UploadResultPlatform(this._metadata, this._ref) : super(token: _token);

  static final Object _token = Object();

  final FullMetadata _metadata;

  final ReferencePlatform _ref;

  /// Throws an [AssertionError] if [instance] does not extend
  /// [UploadResultPlatform].
  ///
  /// This is used by the app-facing [UploadResult] to ensure that
  /// the object in which it's going to delegate calls has been
  /// constructed properly.
  static void verifyExtends(UploadResultPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
  }

  /// The [ReferencePlatform] associated with this upload result.
  ReferencePlatform get ref => _ref;

  /// The [FullMetadata] associated with this task result.
  FullMetadata get metadata => _metadata;
}
