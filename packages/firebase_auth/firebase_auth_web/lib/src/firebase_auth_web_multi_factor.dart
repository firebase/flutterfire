// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:firebase_auth_web/src/firebase_auth_web_user_credential.dart';

import 'interop/auth.dart' as auth;
import 'interop/auth.dart' as auth_interop;
import 'interop/multi_factor.dart' as multi_factor_interop;
import 'utils/web_utils.dart';

/// Web delegate implementation of [UserPlatform].
class MultiFactorWeb extends MultiFactorPlatform {
  MultiFactorWeb(FirebaseAuthPlatform auth, this._webMultiFactorUser)
      : super(auth);

  final multi_factor_interop.MultiFactorUser _webMultiFactorUser;

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
      final webAssertion = assertion as MultiFactorAssertionWeb;
      return await _webMultiFactorUser.enroll(
        webAssertion.assertion,
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
  }) async {
    final uidToUnenroll = factorUid ?? multiFactorInfo?.uid;
    if (uidToUnenroll == null) {
      throw ArgumentError(
        'Either factorUid or multiFactorInfo must not be null',
      );
    }

    try {
      await _webMultiFactorUser.unenroll(
        uidToUnenroll,
      );
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<List<MultiFactorInfo>> getEnrolledFactors() async {
    final data = _webMultiFactorUser.enrolledFactors;
    return data
        .map((e) => MultiFactorInfo(
              factorId: e.factorId,
              enrollmentTimestamp:
                  HttpDate.parse(e.enrollmentTime).millisecondsSinceEpoch /
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
    this._webAuth,
  ) : super(hints, session);

  final multi_factor_interop.MultiFactorResolver _webMultiFactorResolver;
  final auth_interop.Auth? _webAuth;
  final FirebaseAuthWeb _auth;

  @override
  Future<UserCredentialPlatform> resolveSignIn(
    MultiFactorAssertionPlatform assertion,
  ) async {
    final webAssertion = assertion as MultiFactorAssertionWeb;

    try {
      return UserCredentialWeb(
        _auth,
        await _webMultiFactorResolver.resolveSignIn(webAssertion.assertion),
        _webAuth,
      );
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }
}

class MultiFactorSessionWeb extends MultiFactorSession {
  MultiFactorSessionWeb(
    String id,
    this.webSession,
  ) : super(id);

  final multi_factor_interop.MultiFactorSession webSession;
}

/// Helper class used to generate PhoneMultiFactorAssertions.
class PhoneMultiFactorGeneratorWeb extends PhoneMultiFactorGeneratorPlatform {
  /// Transforms a PhoneAuthCredential into a [MultiFactorAssertion]
  /// which can be used to confirm ownership of a phone second factor.
  @override
  MultiFactorAssertionPlatform getAssertion(
    PhoneAuthCredential credential,
  ) {
    final verificationId = credential.verificationId;
    final verificationCode = credential.smsCode;

    if (verificationCode == null) {
      throw ArgumentError('verificationCode must not be null');
    }
    if (verificationId == null) {
      throw ArgumentError('verificationId must not be null');
    }

    final cred =
        auth.PhoneAuthProvider.credential(verificationId, verificationCode);

    return MultiFactorAssertionWeb(
        multi_factor_interop.PhoneMultiFactorGenerator.assertion(cred));
  }
}

class TotpSecretWeb extends TotpSecretPlatform {
  TotpSecretWeb(
      this.webSecret,
      super.codeIntervalSeconds,
      super.codeLength,
      super.enrollmentCompletionDeadline,
      super.hashingAlgorithm,
      super.secretKey);

  final multi_factor_interop.TotpSecret webSecret;

  @override

  /// Generate a TOTP secret for the authenticated user.
  @override
  Future<String> generateQrCodeUrl({
    String? accountName,
    String? issuer,
  }) {
    return Future.value(
      webSecret.generateQrCodeUrl(
        accountName,
        issuer,
      ),
    );
  }

  /// Opens the specified QR Code URL in a password manager like iCloud Keychain.
  @override
  Future<void> openInOtpApp(
    String qrCodeUrl,
  ) async {
    throw UnimplementedError('openInOtpApp() is not available on Web');
  }
}

class TotpMultiFactorGeneratorWeb extends TotpMultiFactorGeneratorPlatform {
  /// Transforms a PhoneAuthCredential into a [MultiFactorAssertion]
  /// which can be used to confirm ownership of a phone second factor.
  @override
  Future<TotpSecretPlatform> generateSecret(
    MultiFactorSession session,
  ) async {
    final _webMultiFactorSession = session as MultiFactorSessionWeb;
    final _webSecret =
        await multi_factor_interop.TotpMultiFactorGenerator.generateSecret(
            _webMultiFactorSession.webSession);

    return TotpSecretWeb(
      _webSecret,
      _webSecret.codeInterval,
      _webSecret.codeLength,
      _webSecret.enrollmentCompletionDeadline,
      _webSecret.hashingAlgorithm,
      _webSecret.secretKey,
    );
  }

  /// Get a [MultiFactorAssertion]
  /// which can be used to confirm ownership of a TOTP second factor.
  @override
  Future<MultiFactorAssertionPlatform> getAssertionForEnrollment(
    TotpSecretPlatform secret,
    String oneTimePassword,
  ) async {
    final _webSecret = secret as TotpSecretWeb;
    final totpAssertion =
        multi_factor_interop.TotpMultiFactorGenerator.assertionForEnrollment(
      _webSecret.webSecret,
      oneTimePassword,
    );
    return MultiFactorAssertionWeb(totpAssertion);
  }

  /// Get a [MultiFactorAssertion]
  /// which can be used to confirm ownership of a TOTP second factor.
  @override
  Future<MultiFactorAssertionPlatform> getAssertionForSignIn(
    String enrollmentId,
    String oneTimePassword,
  ) async {
    final totpAssertion =
        multi_factor_interop.TotpMultiFactorGenerator.assertionForSignIn(
      enrollmentId,
      oneTimePassword,
    );
    return MultiFactorAssertionWeb(totpAssertion);
  }
}
