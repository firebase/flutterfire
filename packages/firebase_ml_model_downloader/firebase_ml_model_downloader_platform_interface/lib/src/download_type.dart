// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A download type to download a custom model when calling the [getModel] API.
enum FirebaseModelDownloadType {
  /// Returns the current model if present, otherwise triggers new download
  /// (or finds one in progress) and only completes when download is finished.
  localModel,

  /// Returns the current model if present and triggers an update to fetch a
  /// new version in the background. If no local model is present triggers a
  /// new download (or finds one in progress) and only completes when download
  /// is finished.
  localModelUpdateInBackground,

  /// Returns the latest model. Checks if latest model is different from local
  /// model. If the models are the same, returns the current model. Otherwise,
  /// triggers a new model download and returns when this download finishes.
  latestModel,
}
