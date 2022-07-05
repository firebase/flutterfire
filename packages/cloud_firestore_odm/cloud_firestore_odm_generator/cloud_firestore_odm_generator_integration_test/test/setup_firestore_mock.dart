import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> setupCloudFirestoreMocks() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  setupFirebaseCoreMocks();
  await Firebase.initializeApp();
}
