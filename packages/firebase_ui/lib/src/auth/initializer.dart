import 'dart:async';

import 'package:firebase_ui/src/firebase_ui_initializer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class FirebaseUIAuthOptions {
  final FirebaseApp? app;
  final ActionCodeSettings? emailLinkSettings;

  FirebaseUIAuthOptions({
    this.emailLinkSettings,
    this.app,
  });
}

class FirebaseUIAuthInitializer
    extends FirebaseUIInitializer<FirebaseUIAuthOptions> {
  FirebaseUIAuthInitializer([FirebaseUIAuthOptions? params]) : super(params);

  late FirebaseAuth? _auth;
  FirebaseAuth get auth => _auth!;

  StreamController<Uri> _links = StreamController.broadcast();
  Stream<Uri> get links => _links.stream;

  @override
  Future<void> initialize([FirebaseUIAuthOptions? params]) async {
    _auth = params?.app != null
        ? FirebaseAuth.instanceFor(app: params!.app!)
        : FirebaseAuth.instance;

    FirebaseDynamicLinks.instance.onLink(
      onSuccess: (dynamicLink) async {
        final deepLink = dynamicLink!.link;
        _links.add(deepLink);

        final code = deepLink.queryParameters['oobCode']!;

        await auth.checkActionCode(code);
        await auth.applyActionCode(code);

        await auth.currentUser!.reload();
      },
    );
  }

  Future<Uri> awaitLink() {
    return links.take(1).toList().then((links) => links.first);
  }
}
