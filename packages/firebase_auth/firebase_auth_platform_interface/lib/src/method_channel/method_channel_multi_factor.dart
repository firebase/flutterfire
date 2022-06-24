import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_platform_interface/src/pigeon/messages.pigeon.dart';

class MethodChannelMultiFactor extends MultiFactorPlatform {
  /// Constructs a new [MethodChannelUser] instance.
  MethodChannelMultiFactor(FirebaseAuthPlatform auth) : super(auth);

  final _api = MultiFactorUserHostApi();

  @override
  Future<MultiFactorSession> getSession() async {
    final pigeonObject = await _api.getSession(auth.app.name);
    return MultiFactorSession(pigeonObject.id);
  }

  @override
  Future<void> enroll(
    MultiFactorAssertion assertion, {
    String? displayName,
  }) async {
    if (assertion.credential is PhoneAuthCredential) {
      final credential = assertion.credential as PhoneAuthCredential;
      final verificationId = credential.verificationId;
      final verificationCode = credential.smsCode;

      if (verificationCode == null) {
        throw ArgumentError('verificationCode must not be null');
      }
      if (verificationId == null) {
        throw ArgumentError('verificationId must not be null');
      }

      await _api.enrollPhone(
        auth.app.name,
        PigeonPhoneMultiFactorAssertion(
          verificationId: verificationId,
          verificationCode: verificationCode,
        ),
        displayName,
      );
    } else {
      throw UnimplementedError(
          'Credential type ${assertion.credential} is not supported yet');
    }
  }
}
