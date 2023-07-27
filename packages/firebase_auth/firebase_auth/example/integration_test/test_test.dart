// ignore_for_file: do_not_use_environment

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_example/firebase_options.dart';
import 'package:firebase_auth_example/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:patrol/patrol.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  patrolTest(
    'log in with Google account',
    nativeAutomation: true,
    ($) async {
      addTearDown(() async {
        final automator = NativeAutomator(
          config: const NativeAutomatorConfig(
            packageName: 'io.flutter.plugins.firebase.auth.example',
          ),
        );

        await automator.configure();
        await automator.openApp();
      });

      addTearDown(() async {
        final automator = NativeAutomator(
          config: const NativeAutomatorConfig(
            packageName: 'io.flutter.plugins.firebase.auth.example',
          ),
        );

        await automator.configure();
        await automator.openApp(appId: 'com.android.settings');
        await swipeUntilVisible(
          automator: automator,
          elementSelector: Selector(
            text: 'Passwords & accounts',
          ),
        );
        await automator.tap(Selector(text: 'Passwords & accounts'));
        await automator
            .tap(Selector(text: const String.fromEnvironment('EMAIL')));
        await automator.tap(Selector(text: 'Remove account'));
        await automator.tap(Selector(text: 'Remove account'));
      });

      // We store the app and auth to make testing with a named instance easier.
      app = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      auth = FirebaseAuth.instanceFor(app: app);
      await $.pumpWidgetAndSettle(
        AuthExampleApp(
          auth: auth,
        ),
      );

      await $.native.grantPermissionOnlyThisTime();

      await $(RegExp('Google')).tap();

      await $.native.enterText(
        Selector(resourceId: 'identifierId'),
        text: const String.fromEnvironment('EMAIL'),
        keyboardBehavior: KeyboardBehavior.alternative,
      );

      await $.native.tap(Selector(resourceId: 'identifierNext'));

      await $.native.enterText(
        Selector(resourceId: 'password'),
        text: const String.fromEnvironment('PASSWORD'),
        keyboardBehavior: KeyboardBehavior.alternative,
      );

      await $.native.tap(Selector(resourceId: 'passwordNext'));

      await $.native.tap(Selector(resourceId: 'signinconsentNext'));

      await $.native.tap(
        Selector(resourceId: 'com.google.android.gms:id/sud_items_switch'),
      );

      await swipeUntilVisible(
        automator: $.native,
        elementSelector: Selector(text: 'ACCEPT'),
      );

      await $.native.tap(Selector(text: 'ACCEPT'));

      await $(const String.fromEnvironment('EMAIL')).waitUntilVisible();

      await $('Sign out').tap();
    },
  );
}

Future<void> swipeUntilVisible({
  required NativeAutomator automator,
  required Selector elementSelector,
}) async {
  while ((await automator.getNativeViews(elementSelector)).isEmpty) {
    await automator.swipe(
      from: const Offset(0.5, 0.7),
      to: const Offset(0.5, 0.3),
    );
  }
}
