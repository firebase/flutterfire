// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

class UserInfo {
  @protected
  UserInfo(this._data);

  final Map<String, dynamic> _data;

  String get displayName {
    return _data['displayName'];
  }

  String get email {
    return _data['email'];
  }

  String get phoneNumber {
    return _data['phoneNumber'];
  }

  String get providerId {
    return _data['providerId'];
  }

  String get uid {
    return _data['uid'];
  }

  @override
  String toString() {
    return '$UserInfo(displayName: $displayName, email: $email, phoneNumber: $phoneNumber, providerId: $providerId, uid: $uid)';
  }
}
