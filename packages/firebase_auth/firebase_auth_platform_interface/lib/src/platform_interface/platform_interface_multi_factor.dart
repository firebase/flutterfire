import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class MultiFactorPlatform extends PlatformInterface {
  /// The [FirebaseAuthPlatform] instance.
  final FirebaseAuthPlatform auth;

  /// Constructs a VideoPlayerPlatform.
  MultiFactorPlatform(
    this.auth,
  ) : super(token: _token);

  static final Object _token = Object();

  static MultiFactorPlatform? _instance;

  /// Sets the [FirebaseAuthPlatform.instance]
  static set instance(MultiFactorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> enroll(MultiFactorAssertion assertion, {String? displayName}) {
    throw UnimplementedError('enroll() is not implemented');
  }

  Future<MultiFactorSession> getSession() {
    throw UnimplementedError('getSession() is not implemented');
  }

// Future<void> unenroll(String factorUid) {}
// Future<List<MultiFactorInfo>> getEnrolledFactors() {}

}

class MultiFactorSession {
  MultiFactorSession(this.id);

  final String id;
}

class MultiFactorAssertion {
  const MultiFactorAssertion(this.credential);

  final AuthCredential credential;
}

class PhoneMultiFactorGenerator {
  static MultiFactorAssertion getAssertion(PhoneAuthCredential credential) {
    return MultiFactorAssertion(credential);
  }
}
