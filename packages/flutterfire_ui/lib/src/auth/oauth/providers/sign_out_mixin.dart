import 'dart:io';

import '../oauth_providers.dart';

mixin SignOutMixin on OAuthProvider {
  @override
  Future<void> signOut() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await logOutProvider();
    }
    return super.signOut();
  }
}
