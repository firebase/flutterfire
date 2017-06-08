import 'package:path/path.dart' as p;

String validDatePath() => p.join('pkg_firebase_test',
    new DateTime.now().toUtc().toIso8601String().replaceAll('.', '_'));

printException(e) => print(
    [e.name, e.code, e.message, e.stack].where((s) => s != null).join('\n'));

String getTestEmail() =>
    '${new DateTime.now().millisecondsSinceEpoch}@example.com';
