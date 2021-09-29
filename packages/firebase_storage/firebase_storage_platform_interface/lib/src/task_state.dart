// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Represents the state of an on-going [Task].
///
/// The state can be accessed directly via a [TaskSnapshot].
enum TaskState {
  /// Indicates the task has been paused by the user.
  paused,

  /// Indicates the task is currently in-progress.
  running,

  /// Indicates the task has successfully completed.
  success,

  /// Indicates the task was canceled.
  canceled,

  /// Indicates the task failed with an error.
  error,
}
