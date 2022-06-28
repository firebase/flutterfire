import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// {@template .platformInterfaceMultiFactor}
/// The platform defining the interface of multi-factor related
/// properties and operations pertaining to a [User].
/// {@endtemplate}
abstract class MultiFactorPlatform extends PlatformInterface {
  /// {@macro .platformInterfaceMultiFactor}
  MultiFactorPlatform(
    this.auth,
  ) : super(token: _token);

  /// The [FirebaseAuthPlatform] instance.
  final FirebaseAuthPlatform auth;

  static final Object _token = Object();

  /// Enrolls a second factor as identified by the [MultiFactorAssertion] parameter for the current user.
  ///
  /// [displayName] can be used to provide a display name for the second factor.
  Future<void> enroll(MultiFactorAssertion assertion, {String? displayName}) {
    throw UnimplementedError('enroll() is not implemented');
  }

  /// Returns a session identifier for a second factor enrollment operation.
  Future<MultiFactorSession> getSession() {
    throw UnimplementedError('getSession() is not implemented');
  }

// Future<void> unenroll(String factorUid) {}
// Future<List<MultiFactorInfo>> getEnrolledFactors() {}

}

/// Identifies the current session to enroll a second factor or to complete sign in when previously enrolled.
///
/// It contains additional context on the existing user, notably the confirmation that the user passed the first factor challenge.
class MultiFactorSession {
  MultiFactorSession(this.id);

  final String id;
}

/// Represents an assertion that the Firebase Authentication server
/// can use to authenticate a user as part of a multi-factor flow.
class MultiFactorAssertion {
  const MultiFactorAssertion._(this.credential);

  /// Associated credential to the assertion
  final AuthCredential credential;
}

/// Helper class used to generate PhoneMultiFactorAssertions.
class PhoneMultiFactorGenerator {
  /// Transforms a PhoneAuthCredential into a [MultiFactorAssertion]
  /// which can be used to confirm ownership of a phone second factor.
  static MultiFactorAssertion getAssertion(PhoneAuthCredential credential) {
    return MultiFactorAssertion._(credential);
  }
}

/// {@macro .platformInterfaceMultiFactorResolverPlatform}
/// Utility class that contains methods to resolve second factor
/// requirements on users that have opted into two-factor authentication.
/// {@endtemplate}
class MultiFactorResolverPlatform {
  /// {@macro .platformInterfaceMultiFactorResolverPlatform}
  const MultiFactorResolverPlatform(
    this.hints,
    this.session,
  );

  /// List of [MultiFactorInfo] which represents the available
  /// second factors that can be used to complete the sign-in for the current session.
  final List<MultiFactorInfo> hints;

  /// A MultiFactorSession, an opaque session identifier for the current sign-in flow.
  final MultiFactorSession session;

  /// Completes sign in with a second factor using an MultiFactorAssertion which
  /// confirms that the user has successfully completed the second factor challenge.
  Future<UserCredentialPlatform> resolveSignIn(
    MultiFactorAssertion assertion,
  ) {
    throw UnimplementedError('resolveSignIn() is not implemented');
  }
}

/// Represents a single second factor means for the user.
///
/// See direct subclasses for type-specific information.
class MultiFactorInfo {
  const MultiFactorInfo({
    required this.factorId,
    required this.enrollmentTimestamp,
    required this.displayName,
    required this.uid,
  });

  /// User-given display name for this second factor.
  final String? displayName;

  /// The enrollment timestamp for this second factor in seconds since epoch (UTC midnight on January 1, 1970).
  final double enrollmentTimestamp;

  /// The factor id of this second factor.
  final String factorId;

  /// The unique identifier for this second factor.
  final String uid;
}

/// Represents the information for a phone second factor.
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

  /// The phone number associated with this second factor verification method.
  final String phoneNumber;
}
