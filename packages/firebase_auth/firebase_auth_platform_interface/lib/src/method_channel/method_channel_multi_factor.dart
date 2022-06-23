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
}
