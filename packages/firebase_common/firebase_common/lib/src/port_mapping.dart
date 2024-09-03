part of firebase_common;

String getMappedHost(String originalHost) {
  String mappedHost = originalHost;

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    if (mappedHost == 'localhost' || mappedHost == '127.0.0.1') {
      // ignore: avoid_print
      print('Mapping Auth Emulator host "$mappedHost" to "10.0.2.2".');
      mappedHost = '10.0.2.2';
    }
  }
  return mappedHost;
}
