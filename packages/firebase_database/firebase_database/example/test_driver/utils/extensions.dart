import 'package:firebase_database/firebase_database.dart' show DataSnapshot;

extension KeysGetter on DataSnapshot {
  List<String> get keys {
    final keys = <String>[];

    children.forEach((snapshot) {
      keys.add(snapshot.key!);
    });

    return keys;
  }
}
