// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

enum ActionCodeInfoOperation {
  emailSignIn,
  passwordReset,
  recoverEmail,
  revertSecondFactorAddition,
  verifyAndChangeEmail,
  verifyEmail,
}

class ActionCodeInfo {
  ActionCodeInfo({
    int operation,
    Map<String, dynamic> data,
  })  : _operation = operation,
        _data = data;

  int _operation;

  Map<String, dynamic> _data;

  ActionCodeInfoOperation get operation {
    switch (_operation) {
      case 4:
        return ActionCodeInfoOperation.emailSignIn;
      case 0:
        return ActionCodeInfoOperation.passwordReset;
      case 2:
        return ActionCodeInfoOperation.recoverEmail;
      case 6:
        return ActionCodeInfoOperation.revertSecondFactorAddition;
      case 5:
        return ActionCodeInfoOperation.verifyAndChangeEmail;
      case 1:
        return ActionCodeInfoOperation.verifyEmail;
      default:
        throw FallThroughError();
    }
  }

  Map<String, dynamic> get data {
    return <String, dynamic>{
      'email': _data['email'],
      'previousEmail': _data['previousEmail'],
    };
  }
}
