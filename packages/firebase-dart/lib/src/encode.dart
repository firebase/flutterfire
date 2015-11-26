library firebase.encode;

import 'consts.dart';

String encodeKey(String input) {
  return input.replaceAllMapped(_escapeRegExp, (match) {
    var value = match[0];
    return _invalidKeyMap[value];
  });
}

String decodeKey(String input) {
  return input.replaceAllMapped(_decodeRegExp, (match) {
    var value = match[0];
    return _decodeMap[value];
  });
}

final _invalidKeyMap = new Map.unmodifiable(new Map.fromIterable(
    invalidFirebaseKeyCharsAndStar,
    value: (i) => _getEncodedLiteral(i)));

final _decodeMap = new Map.unmodifiable(new Map.fromIterable(
    invalidFirebaseKeyCharsAndStar,
    key: (i) => _getEncodedLiteral(i)));

/// A [RegExp] that matches whitespace characters that should be escaped.
final _escapeRegExp =
    new RegExp("[${invalidFirebaseKeyCharsAndStar.map((i) => '\\$i').join()}]");

final _decodeRegExp = new RegExp('\\${encodeChar}[0-9A-F]{2}');

/// Given single-character string, return the hex-escaped equivalent.
String _getEncodedLiteral(String input) {
  int rune = input.runes.single;
  return encodeChar + rune.toRadixString(16).toUpperCase().padLeft(2, '0');
}
