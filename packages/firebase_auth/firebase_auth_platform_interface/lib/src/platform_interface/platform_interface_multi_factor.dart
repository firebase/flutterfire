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

class MultiFactorResolverPlatform {
  const MultiFactorResolverPlatform(
    this.hints,
    this.session,
  );

  final List<MultiFactorInfo> hints;

  final MultiFactorSession session;

  Future<UserCredentialPlatform> resolveSignIn(
    MultiFactorAssertion assertion,
  ) {
    throw UnimplementedError('resolveSignIn() is not implemented');
  }
}

class MultiFactorInfo {
  const MultiFactorInfo({
    required this.factorId,
    required this.enrollmentTimestamp,
    required this.displayName,
    required this.uid,
  });

  final String? displayName;
  final double enrollmentTimestamp;
  final String factorId;
  final String uid;
}

class PhoneMultiFactorInfo extends MultiFactorInfo {
  const PhoneMultiFactorInfo({
    required String? displayName,
    required double enrollmentTimestamp,
    required String factorId,
    required String uid,
    required this.phoneNumber,
  }) : super(
          displayName: displayName,
          enrollmentTimestamp: enrollmentTimestamp,
          factorId: factorId,
          uid: uid,
        );

  final String phoneNumber;
}
