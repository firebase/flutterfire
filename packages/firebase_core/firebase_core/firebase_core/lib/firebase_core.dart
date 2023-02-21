
import 'firebase_core_platform_interface.dart';

class FirebaseCore {
  Future<String?> getPlatformVersion() {
    return FirebaseCorePlatform.instance.getPlatformVersion();
  }
}
