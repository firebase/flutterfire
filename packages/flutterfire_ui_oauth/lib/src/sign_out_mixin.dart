import 'dart:io';

import 'oauth_provider.dart';

mixin SignOutMixin on OAuthProvider {
  @override
  Future<void> signOut() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await logOutProvider();
    }
    return super.signOut();
  }
}
