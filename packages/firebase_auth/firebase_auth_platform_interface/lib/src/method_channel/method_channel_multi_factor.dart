// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_platform_interface/src/method_channel/method_channel_firebase_auth.dart';
import 'package:firebase_auth_platform_interface/src/method_channel/method_channel_user_credential.dart';
import 'package:firebase_auth_platform_interface/src/method_channel/utils/exception.dart';
import 'package:firebase_auth_platform_interface/src/method_channel/utils/pigeon_helper.dart';
import 'package:firebase_auth_platform_interface/src/pigeon/messages.pigeon.dart';

class MethodChannelMultiFactor extends MultiFactorPlatform {
  /// Constructs a new [MethodChannelMultiFactor] instance.
  MethodChannelMultiFactor(FirebaseAuthPlatform auth) : super(auth);

  final _api = MultiFactorUserHostApi();

  PigeonFirebaseApp get pigeonDefault {
    return PigeonFirebaseApp(
      appName: auth.app.name,
      tenantId: auth.tenantId,
    );
  }

  @override
  Future<MultiFactorSession> getSession() async {
    try {
      final pigeonObject = await _api.getSession(pigeonDefault);
      return MultiFactorSession(pigeonObject.id);
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<void> enroll(
    MultiFactorAssertionPlatform assertion, {
    String? displayName,
  }) async {
    final _assertion = assertion as MultiFactorAssertion;

    if (_assertion.credential is PhoneAuthCredential) {
      final credential = _assertion.credential! as PhoneAuthCredential;
      final verificationId = credential.verificationId;
      final verificationCode = credential.smsCode;

      if (verificationCode == null) {
        throw ArgumentError('verificationCode must not be null');
      }
      if (verificationId == null) {
        throw ArgumentError('verificationId must not be null');
      }

      try {
        await _api.enrollPhone(
          pigeonDefault,
          PigeonPhoneMultiFactorAssertion(
            verificationId: verificationId,
            verificationCode: verificationCode,
          ),
          displayName,
        );
      } catch (e, stack) {
        convertPlatformException(e, stack);
      }
    } else if (_assertion is TotpMultiFactorAssertion) {
      try {
        await _api.enrollTotp(
          pigeonDefault,
          _assertion.assertionId,
          displayName,
        );
      } catch (e, stack) {
        convertPlatformException(e, stack);
      }
    } else {
      throw UnimplementedError(
        'Credential type ${_assertion.credential} is not supported yet',
      );
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
      await _api.unenroll(
        pigeonDefault,
        uidToUnenroll,
      );
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<List<MultiFactorInfo>> getEnrolledFactors() async {
    try {
      final data = await _api.getEnrolledFactors(pigeonDefault);
      return multiFactorInfoPigeonToObject(data);
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }
}

class MethodChannelMultiFactorResolver extends MultiFactorResolverPlatform {
  MethodChannelMultiFactorResolver(
    List<MultiFactorInfo> hints,
    MultiFactorSession session,
    String resolverId,
    MethodChannelFirebaseAuth auth,
  )   : _resolverId = resolverId,
        _auth = auth,
        super(hints, session);

  final String _resolverId;

  final MethodChannelFirebaseAuth _auth;
  final _api = MultiFactoResolverHostApi();

  @override
  Future<UserCredentialPlatform> resolveSignIn(
    MultiFactorAssertionPlatform assertion,
  ) async {
    final _assertion = assertion as MultiFactorAssertion;

    if (_assertion.credential is PhoneAuthCredential) {
      final credential = _assertion.credential! as PhoneAuthCredential;
      final verificationId = credential.verificationId;
      final verificationCode = credential.smsCode;

      if (verificationCode == null) {
        throw ArgumentError('verificationCode must not be null');
      }
      if (verificationId == null) {
        throw ArgumentError('verificationId must not be null');
      }

      try {
        final result = await _api.resolveSignIn(
          _resolverId,
          PigeonPhoneMultiFactorAssertion(
            verificationId: verificationId,
            verificationCode: verificationCode,
          ),
          null,
        );

        MethodChannelUserCredential userCredential =
            MethodChannelUserCredential(_auth, result);

        return userCredential;
      } catch (e, stack) {
        convertPlatformException(e, stack);
      }
    } else if (_assertion is TotpMultiFactorAssertion) {
      try {
        final result = await _api.resolveSignIn(
          _resolverId,
          null,
          _assertion.assertionId,
        );

        MethodChannelUserCredential userCredential =
            MethodChannelUserCredential(_auth, result);

        return userCredential;
      } catch (e, stack) {
        convertPlatformException(e, stack);
      }
    } else {
      throw UnimplementedError(
        'Credential type ${_assertion.credential} is not supported yet',
      );
    }
  }
}

/// Represents an assertion that the Firebase Authentication server
/// can use to authenticate a user as part of a multi-factor flow.
class MultiFactorAssertion extends MultiFactorAssertionPlatform {
  MultiFactorAssertion(this.credential) : super();

  /// Associated credential to the assertion
  final AuthCredential? credential;
}

class PhoneMultiFactorAssertion extends MultiFactorAssertion {
  PhoneMultiFactorAssertion(
    PhoneAuthCredential credential,
  ) : super(credential);
}

/// Helper class used to generate PhoneMultiFactorAssertions.
class MethodChannelPhoneMultiFactorGenerator
    extends PhoneMultiFactorGeneratorPlatform {
  /// Transforms a PhoneAuthCredential into a [MultiFactorAssertion]
  /// which can be used to confirm ownership of a phone second factor.
  @override
  MultiFactorAssertionPlatform getAssertion(
    PhoneAuthCredential credential,
  ) {
    return PhoneMultiFactorAssertion(credential);
  }
}

class TotpMultiFactorAssertion extends MultiFactorAssertion {
  TotpMultiFactorAssertion(
    this.assertionId,
  ) : super(null);

  final String assertionId;
}

/// Helper class used to generate PhoneMultiFactorAssertions.
class MethodChannelTotpMultiFactorGenerator
    extends TotpMultiFactorGeneratorPlatform {
  final _api = MultiFactorTotpHostApi();

  /// Transforms a PhoneAuthCredential into a [MultiFactorAssertion]
  /// which can be used to confirm ownership of a phone second factor.
  @override
  Future<TotpSecretPlatform> generateSecret(
    MultiFactorSession session,
  ) async {
    final pigeonSecret = await _api.generateSecret(session.id);
    return MethodChannelTotpSecret(
      pigeonSecret.codeIntervalSeconds,
      pigeonSecret.codeLength,
      pigeonSecret.enrollmentCompletionDeadline != null
          ? DateTime.fromMillisecondsSinceEpoch(
              pigeonSecret.enrollmentCompletionDeadline!,
            )
          : null,
      pigeonSecret.hashingAlgorithm,
      pigeonSecret.secretKey,
    );
  }

  /// Get a [MultiFactorAssertion]
  /// which can be used to confirm ownership of a TOTP second factor.
  @override
  Future<MultiFactorAssertionPlatform> getAssertionForEnrollment(
    TotpSecretPlatform secret,
    String oneTimePassword,
  ) async {
    final totpAssertionId =
        await _api.getAssertionForEnrollment(secret.secretKey, oneTimePassword);
    return TotpMultiFactorAssertion(totpAssertionId);
  }

  /// Get a [MultiFactorAssertion]
  /// which can be used to confirm ownership of a TOTP second factor.
  @override
  Future<MultiFactorAssertionPlatform> getAssertionForSignIn(
    String enrollmentId,
    String oneTimePassword,
  ) async {
    final totpAssertionId =
        await _api.getAssertionForSignIn(enrollmentId, oneTimePassword);
    return TotpMultiFactorAssertion(totpAssertionId);
  }
}

/// Helper class used to generate PhoneMultiFactorAssertions.
class MethodChannelTotpSecret extends TotpSecretPlatform {
  MethodChannelTotpSecret(
    super.codeIntervalSeconds,
    super.codeLength,
    super.enrollmentCompletionDeadline,
    super.hashingAlgorithm,
    super.secretKey,
  );

  final _api = MultiFactorTotpSecretHostApi();

  /// Returns a QR code URL as described in https://github.com/google/google-authenticator/wiki/Key-Uri-Format
  /// This can be displayed to the user as a QR code to be scanned into a TOTP app like Google Authenticator.
  /// If the optional parameters are unspecified, an accountName of and issuer of are used.
  @override
  Future<String> generateQrCodeUrl({
    String? accountName,
    String? issuer,
  }) async {
    final pigeonResponse = await _api.generateQrCodeUrl(
      secretKey,
      accountName,
      issuer,
    );
    return pigeonResponse;
  }

  /// Opens the specified QR Code URL in a password manager like iCloud Keychain.
  @override
  Future<void> openInOtpApp(
    String qrCodeUrl,
  ) async {
    await _api.openInOtpApp(
      secretKey,
      qrCodeUrl,
    );
  }
}
