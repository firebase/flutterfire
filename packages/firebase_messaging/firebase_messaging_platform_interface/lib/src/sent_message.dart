// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';

/// Represents a sent message response when calling [sendMessage].
/// 
/// The result of which can be listened to via [onMessageSent].
class SentMessage {
  const SentMessage._(this.messageId, this.error);

  /// The message ID.
  /// 
  /// This value is provided for both successful and failed sent messages.
  final String messageId;

  /// If the message failed to send, a [FirebaseException] will be provided, or
  /// `null` if it was successful.
  final FirebaseException error;
}
