// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dart_cloud_functions/src/context.dart';
import 'package:dart_cloud_functions/src/firebase_functions_exception.dart';

/// The region of emulator URLs when [callableUrl] gets a custom domain, as in
/// the native SDKs.
const _defaultRegion = 'us-central1';

/// Hosts that may receive tokens over plain HTTP: the device itself, and
/// `10.0.2.2`, the Android emulator's address for the host machine.
const _loopbackHosts = {'localhost', '127.0.0.1', '::1', '10.0.2.2'};

/// Resolves the URL of a callable function.
///
/// An explicit [uri] is used as is, even when an emulator [origin] is set,
/// which matches the native SDKs. Otherwise [name] is resolved against the
/// emulator (`{origin}/{projectId}/{region}/{name}`) or production
/// (`https://{region}-{projectId}.cloudfunctions.net/{name}`).
///
/// As in the native SDKs, [region] may instead be a custom domain such as
/// `https://example.com`, which sends calls to `https://example.com/{name}`.
/// The emulator still takes priority, with the default region.
Uri callableUrl({
  required String projectId,
  required String region,
  String? name,
  Uri? uri,
  String? origin,
}) {
  if (uri != null) return uri;
  if (name == null) {
    throw ArgumentError('Either a function name or a URI is required.');
  }
  final customDomain = _customDomain(region);
  if (origin != null) {
    final emulatorRegion = customDomain == null ? region : _defaultRegion;
    return Uri.parse('$origin/$projectId/$emulatorRegion/$name');
  }
  if (customDomain != null) return Uri.parse('$customDomain/$name');
  return Uri.https('$region-$projectId.cloudfunctions.net', name);
}

/// Returns [region] without a trailing slash if it's a URL such as
/// `https://example.com`, or `null` if it's the name of a region.
String? _customDomain(String region) {
  final url = Uri.tryParse(region);
  if (url == null || !url.hasScheme || url.host.isEmpty) return null;
  return region.endsWith('/') ? region.substring(0, region.length - 1) : region;
}

/// Throws an `unauthenticated` [DartFirebaseFunctionsException] if
/// [context]'s tokens would be sent over plain HTTP to a non-loopback host.
///
/// Tokens are credentials, so, as with `shouldAttachTokens` in the Apple SDK,
/// they only travel over HTTPS or to the local machine, such as the
/// emulator. A call without tokens may use any URL. [allowInsecure] skips the
/// check, for `DartFirebaseFunctions.allowInsecureTokenAttachment`.
void checkTokenTransport(
  Uri url,
  CallableContext context, {
  bool allowInsecure = false,
}) {
  if (!context.hasTokens || allowInsecure || url.scheme == 'https') {
    return;
  }
  if (_loopbackHosts.contains(url.host.toLowerCase())) return;
  throw DartFirebaseFunctionsException(
    code: 'unauthenticated',
    message: 'Refusing to send tokens over HTTP to ${url.host}, which is '
        'not a loopback host.',
  );
}
