// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

const String testDisabledEmail = 'disabled@example.com';
const String testEmail = 'test@example.com';
const String testPassword = 'testpassword';
const String testPhoneNumber = '+447111555666';
const String _testFirebaseProjectId = 'flutterfire-e2e-tests';

// TODO can this be moved to be shared for all plugins that use emulators?
String get testEmulatorHost {
  if (defaultTargetPlatform == TargetPlatform.android && !kIsWeb) {
    return '10.0.2.2';
  }
  return 'localhost';
}

const int testEmulatorPort = 9099;

class EmulatorOobCode {
  @protected
  EmulatorOobCode({
    this.type,
    this.email,
    this.oobCode,
    this.oobLink,
  });

  final EmulatorOobCodeType? type;
  final String? email;
  final String? oobCode;
  final String? oobLink;
}

enum EmulatorOobCodeType {
  emailSignIn,
  passwordReset,
  recoverEmail,
  verifyEmail,
}

String generateRandomEmail({
  String prefix = '',
  String suffix = '@foo.bar',
}) {
  var uuid = createCryptoRandomString();
  var testEmail = prefix + uuid + suffix;
  return testEmail;
}

/// Deletes all users from the Auth emulator.
Future<void> emulatorClearAllUsers() async {
  await http.delete(
    Uri.parse(
      'http://$testEmulatorHost:$testEmulatorPort/emulator/v1/projects/$_testFirebaseProjectId/accounts',
    ),
    headers: {
      'Authorization': 'Bearer owner',
    },
  );
}

/// Disable a specific user by uid.
Future<void> emulatorDisableUser(String uid) async {
  String body = jsonEncode({'disableUser': true, 'localId': uid});
  await http.post(
    Uri.parse(
      'http://$testEmulatorHost:$testEmulatorPort/identitytoolkit.googleapis.com/v1/accounts:update',
    ),
    headers: {
      'Authorization': 'Bearer owner',
      'Content-Type': 'application/json',
      'Content-Length': '${body.length}',
    },
    body: body,
  );
}

/// Retrieve a sms phone authentication code that may have been sent for a specific
/// phone number.
Future<String?> emulatorPhoneVerificationCode(String phoneNumber) async {
  final response = await http.get(
    Uri.parse(
      'http://$testEmulatorHost:$testEmulatorPort/emulator/v1/projects/$_testFirebaseProjectId/verificationCodes',
    ),
    headers: {
      'Authorization': 'Bearer owner',
    },
  );
  final responseBody = Map<String, dynamic>.from(jsonDecode(response.body));
  final verificationCodes =
      List<Map<String, dynamic>>.from(responseBody['verificationCodes']);
  return verificationCodes.reversed.firstWhere(
    (verificationCode) => verificationCode['phoneNumber'] == phoneNumber,
    orElse: () => {'code': 'NOT_FOUND'},
  )['code'];
}

/// Verify an email with an oobCode
///
/// Check [emulatorOutOfBandCode] to get an oobCode.
Future<void> emulatorVerifyEmail(String oobCode) async {
  await http.get(
    Uri.parse(
      'http://$testEmulatorHost:$testEmulatorPort/emulator/action?mode=verifyEmail&lang=en&oobCode=$oobCode&apiKey=fake-api-key',
    ),
  );
}

/// Retrieve a out of band authentication code from the emulator. Useful for testing
/// APIs such as email verification and password resetting.
Future<EmulatorOobCode?> emulatorOutOfBandCode(
  String email,
  EmulatorOobCodeType type,
) async {
  final response = await http.get(
    Uri.parse(
      'http://$testEmulatorHost:$testEmulatorPort/emulator/v1/projects/$_testFirebaseProjectId/oobCodes',
    ),
    headers: {
      'Authorization': 'Bearer owner',
    },
  );

  String? requestType;
  switch (type) {
    case EmulatorOobCodeType.emailSignIn:
      requestType = 'EMAIL_SIGNIN';
      break;
    case EmulatorOobCodeType.passwordReset:
      requestType = 'PASSWORD_RESET';
      break;
    case EmulatorOobCodeType.recoverEmail:
      requestType = 'RECOVER_EMAIL';
      break;
    case EmulatorOobCodeType.verifyEmail:
      requestType = 'VERIFY_EMAIL';
      break;
  }

  final responseBody = Map<String, dynamic>.from(jsonDecode(response.body));
  final oobCodes = List<Map<String, dynamic>>.from(responseBody['oobCodes']);
  final oobCode = oobCodes.reversed.firstWhereOrNull(
    (oobCode) =>
        oobCode['email'] == email && oobCode['requestType'] == requestType,
  );

  if (oobCode == null) {
    return null;
  }

  return EmulatorOobCode(
    type: type,
    email: oobCode['email'],
    oobCode: oobCode['oobCode'],
    oobLink: oobCode['oobLink'],
  );
}

/// Create a custom authentication token with optional claims and tenant id.
/// Useful for testing signInWithCustomToken, custom claims and tenant id data.
// Reverse engineered from;
//  - https://github.com/firebase/firebase-admin-node/blob/d961c3f705a8259762a796ac4f4d6a6dd0992eb1/src/auth/token-generator.ts#L236-L254
//  - https://github.com/firebase/firebase-admin-node/blob/d961c3f705a8259762a796ac4f4d6a6dd0992eb1/src/auth/token-generator.ts#L309-L365
String emulatorCreateCustomToken(
  String uid, {
  Map<String, Object> claims = const {},
  String tenantId = '',
}) {
  final int iat = (DateTime.now().millisecondsSinceEpoch / 1000).floor();

  final String jwtHeaderEncoded = base64
      .encode(
        utf8.encode(
          jsonEncode({
            'alg': 'none',
            'typ': 'JWT',
          }),
        ),
      )
      // Note that base64 padding ("=") must be omitted as per JWT spec.
      .replaceAll(RegExp(r'=+$'), '');

  Map<String, Object> jwtBody = {
    'aud':
        'https://identitytoolkit.googleapis.com/google.identity.identitytoolkit.v1.IdentityToolkit',
    'iat': iat,
    'exp': iat + const Duration(hours: 1).inSeconds,
    'iss': 'firebase-auth-emulator@example.com',
    'sub': 'firebase-auth-emulator@example.com',
    'uid': uid,
  };
  if (claims.isNotEmpty) {
    jwtBody['claims'] = claims;
  }
  if (tenantId.isNotEmpty) {
    jwtBody['tenant_id'] = tenantId;
  }

  final String jwtBodyEncoded = base64
      .encode(utf8.encode(jsonEncode(jwtBody)))
      // Note that base64 padding ("=") must be omitted as per JWT spec.
      .replaceAll(RegExp(r'=+$'), '');

  // Alg is set to none so signature should be empty.
  const String jwtSignature = '';
  return '$jwtHeaderEncoded.$jwtBodyEncoded.$jwtSignature';
}

Future<void> ensureSignedIn(String testEmail) async {
  if (FirebaseAuth.instance.currentUser == null) {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('ensureSignedIn Error $e');
    }
  }
}

Future<void> ensureSignedOut() async {
  if (FirebaseAuth.instance.currentUser != null) {
    await FirebaseAuth.instance.signOut();
  }
}

Random _random = Random.secure();

String createCryptoRandomString([int length = 32]) {
  var values = List<int>.generate(length, (i) => _random.nextInt(256));

  return base64Url.encode(values).toLowerCase();
}
