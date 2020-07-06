import 'package:uuid/uuid.dart';

// Random timebased email to ensure unique test user account
// each time.
String TEST_PASSWORD = 'testpassword';
String generateRandomEmail({prefix = '', suffix = '@foo.bar'}) {
  var uuid = Uuid().v1();
  var testEmail = prefix + uuid + suffix;

  return testEmail;
}
