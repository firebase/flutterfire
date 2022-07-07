// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:firebase_auth_web/src/firebase_auth_web_user_credential.dart';

import 'interop/multi_factor.dart' as multi_factor_interop;
import 'utils/web_utils.dart';

/// Web delegate implementation of [UserPlatform].
class MultiFactorWeb extends MultiFactorPlatform {
  MultiFactorWeb(FirebaseAuthPlatform auth, this._webMultiFactorUser)
      : super(auth);

  final multi_factor_interop.MultiFactorUser _webMultiFactorUser;

  final mapAssertion =
      <multi_factor_interop.MultiFactorAssertion, MultiFactorAssertionWeb>{};

  @override
  Future<MultiFactorSession> getSession() async {
    try {
      return convertMultiFactorSession(await _webMultiFactorUser.session);
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<void> enroll(
    MultiFactorAssertionPlatform assertion, {
    String? displayName,
  }) async {
    try {
      final webAssertion = mapAssertion.keys
          .firstWhere((element) => mapAssertion[element] == assertion);
      return await _webMultiFactorUser.enroll(
        webAssertion,
        displayName,
      );
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<void> unenroll({
    String? factorUid,
    MultiFactorInfo? multiFactorInfo,
  }) {
    final uidToUnenroll = factorUid ?? multiFactorInfo?.uid;
    if (uidToUnenroll == null) {
      throw ArgumentError(
        'Either factorUid or multiFactorInfo must not be null',
      );
    }

    return _webMultiFactorUser.unenroll(
      uidToUnenroll,
    );
  }

  @override
  Future<List<MultiFactorInfo>> getEnrolledFactors() async {
    final data = _webMultiFactorUser.enrolledFactors;
    return data
        .map((e) => MultiFactorInfo(
              factorId: e.factorId,
              enrollmentTimestamp:
                  DateTime.parse(e.enrollmentTime).millisecondsSinceEpoch /
                      1000,
              displayName: e.displayName,
              uid: e.uid,
            ))
        .toList();
  }
}

class MultiFactorAssertionWeb extends MultiFactorAssertionPlatform {
  MultiFactorAssertionWeb(
    this.assertion,
  ) : super();

  final multi_factor_interop.MultiFactorAssertion assertion;
}

class MultiFactorResolverWeb extends MultiFactorResolverPlatform {
  MultiFactorResolverWeb(
    List<MultiFactorInfo> hints,
    MultiFactorSession session,
    this._auth,
    this._webMultiFactorResolver,
  ) : super(hints, session);

  final multi_factor_interop.MultiFactorResolver _webMultiFactorResolver;
  final FirebaseAuthWeb _auth;

  @override
  Future<UserCredentialPlatform> resolveSignIn(
    MultiFactorAssertionPlatform assertion,
  ) async {
    final webAssertion = assertion as MultiFactorAssertionWeb;

    return UserCredentialWeb(
      _auth,
      await _webMultiFactorResolver.resolveSignIn(webAssertion.assertion),
    );
  }
}
