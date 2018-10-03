import 'package:path/path.dart' as p;
import 'package:test/test.dart';

String validDatePath() => p.join('pkg_firebase_test', validDatePathComponent());

String validDatePathComponent() =>
    DateTime.now().toUtc().toIso8601String().replaceAll('.', '_');

printException(e) => print(
    [e.name, e.code, e.message, e.stack].where((s) => s != null).join('\n'));

String getTestEmail() => '${DateTime.now().millisecondsSinceEpoch}@example.com';

Matcher throwsToString(value) => throwsA(_ToStringMatcher(value));

class _ToStringMatcher extends CustomMatcher {
  _ToStringMatcher(matcher)
      : super("Object toString value", "toString", matcher);

  @override
  featureValueOf(actual) => actual.toString();
}
