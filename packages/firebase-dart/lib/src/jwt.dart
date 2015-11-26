library firebase.jwt;

import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Header used by Firebase
/// See https://www.firebase.com/docs/rest/guide/user-auth.html#section-tokens-without-helpers
const _jwtHeader = const <String, String>{"alg": "HS256", "typ": "JWT"};

/// Due to differences of clock speed, network latency, etc. we
/// will shorten expiry dates by 20 seconds.
const _MAX_EXPECTED_TIMEDIFF_IN_SECONDS = 20;

/// If provided, [issuedAtTime] is used to set the `iat` claims header. This may
/// be useful for testing. The default value is `new DateTime.now()` shifted 20
/// seconds into the past to account for possible clock skew.
String createFirebaseJwtToken(String secret,
    {Map<String, dynamic> data,
    bool admin,
    bool debug,
    DateTime issuedAtTime}) {
  if (data == null) data = const {};

  if (issuedAtTime == null) {
    issuedAtTime =
        new DateTime.now().toUtc().subtract(const Duration(seconds: 20));
  } else {
    issuedAtTime = issuedAtTime.toUtc();
  }
  int timestamp = issuedAtTime.millisecondsSinceEpoch ~/ 1000;

  // createOptionsClaimns
  var claims = <String, dynamic>{'v': 0, 'iat': timestamp, 'd': data};

  if (admin == true) {
    claims['admin'] = true;
  }

  if (debug == true) {
    claims['debug'] = true;
  }

  // TODO: more optional fields:
  // https://www.firebase.com/docs/rest/guide/user-auth.html#section-tokens-without-helpers
  // - nbf
  // - exp

  return createJwtToken(_jwtHeader, claims, secret);
}

/// See http://jwt.io/ for details
String createJwtToken(
    Map<String, dynamic> header, Map<String, dynamic> payload, String secret) {
  var encoder = new JsonUtf8Encoder();

  var headerBytes = encoder.convert(header);
  var headerBas64 = _base64url(headerBytes);

  var payloadBytes = encoder.convert(payload);
  var payloadBase64 = _base64url(payloadBytes);

  var sha256 = new SHA256();

  var secretBytes = ASCII.encode(secret);

  var hmac = new HMAC(sha256, secretBytes);

  var hashSourceBytes = ASCII.encode('$headerBas64.$payloadBase64');

  hmac.add(hashSourceBytes);

  var allTheBytes = hmac.close();

  var secretBase64 = _base64url(allTheBytes);

  return '$headerBas64.$payloadBase64.$secretBase64';
}

String _base64url(List<int> bytes) => CryptoUtils
    .bytesToBase64(bytes)
    .replaceAll('+', '-')
    .replaceAll('/', '_')
    .replaceAll('=', '');
