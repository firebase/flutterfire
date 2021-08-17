import 'dart:async';

import 'package:firebase_ui/src/firebase_ui_initializer.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class FirebaseUIDynamicLinksInitializer extends FirebaseUIInitializer {
  StreamController<Uri> _links = StreamController.broadcast();
  Stream<Uri> get links => _links.stream;

  @override
  Future<void> initialize() async {
    FirebaseDynamicLinks.instance.onLink(
      onSuccess: (dynamicLink) async {
        final deepLink = dynamicLink!.link;
        _links.add(deepLink);
      },
    );
  }

  Future<Uri> awaitLink() {
    return links.take(1).toList().then((links) => links.first);
  }
}
