library firebase.test.shared;

import 'package:firebase/src/consts.dart';
import 'package:firebase/src/encode.dart';

const TEST_DOMAIN = 'boiling-fire-3310.firebaseio.com';

// Update TEST_URL to a valid URL and update AUTH_TOKEN to a corresponding
// authentication token to test authentication.
const AUTH_TOKEN = '5KxwqxGbNU0Mrje2NGnSFJZsd3KaTVeUtcVhorMl';

const INVALID_AUTH_TOKEN = 'xbKOOdkZDBExtKM3sZw6gWtFpGgqMkMidXCiAFjm';

final _dateKey = new DateTime.now().toUtc();

String testKey([DateTime date]) {
  if (date == null) {
    date = _dateKey;
  } else {
    date = date.toUtc();
  }

  return encodeKey(date.toIso8601String());
}

DateTime parseTestKey(String value) {
  value = decodeKey(value);
  return DateTime.parse(value);
}

Uri getTestUrlBase(List<String> segments) =>
    new Uri(scheme: 'https', host: TEST_DOMAIN, pathSegments: segments);

final invalidKeyString = invalidFirebaseKeyCharsAndStar.join(' with ') +
    ' and pre-encoded *2E and percent itself *25';
