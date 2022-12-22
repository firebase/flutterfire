// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_ui_oauth/firebase_ui_oauth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';

class FakeAssetBundle extends Fake implements AssetBundle {
  final String svgStr = '''<svg viewBox="0 0 10 10"></svg>''';

  @override
  Future<String> loadString(String key, {bool cache = true}) async => svgStr;
}

class FakeOAuthProvider extends OAuthProvider {
  @override
  ProviderArgs get desktopSignInArgs => throw UnimplementedError();

  @override
  get firebaseAuthProvider => throw UnimplementedError();

  @override
  OAuthCredential fromDesktopAuthResult(AuthResult result) {
    throw UnimplementedError();
  }

  @override
  Future<void> logOutProvider() {
    throw UnimplementedError();
  }

  @override
  void mobileSignIn(AuthAction action) {}

  @override
  String get providerId => 'fake';

  @override
  ThemedOAuthProviderButtonStyle get style => const GoogleProviderButtonStyle();

  @override
  bool supportsPlatform(TargetPlatform platform) {
    return true;
  }
}

class FakeAuth extends Fake implements FirebaseAuth {}

void main() {
  final provider = FakeOAuthProvider();

  const style = GoogleProviderButtonStyle();
  late Widget button;

  Widget renderMaterialButton([Brightness brightness = Brightness.dark]) {
    button = OAuthProviderButtonBase(
      provider: provider,
      label: 'Sign in with Google',
      loadingIndicator: const CircularProgressIndicator(),
      auth: FakeAuth(),
    );

    return DefaultAssetBundle(
      bundle: FakeAssetBundle(),
      child: MaterialApp(
        theme: ThemeData(brightness: brightness),
        home: Scaffold(body: button),
      ),
    );
  }

  group('OAuthProviderButton', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(renderMaterialButton());

      final textFinder = find.text('Sign in with Google');
      expect(textFinder, findsOneWidget);
    });

    testWidgets('applies background color from style', (tester) async {
      await tester.pumpWidget(renderMaterialButton());

      final expectedColor = style.backgroundColor.getValue(Brightness.dark);

      final containerFinder = find.byWidgetPredicate((widget) {
        return widget is Material && widget.color!.value == expectedColor.value;
      });

      expect(containerFinder, findsOneWidget);
    });

    testWidgets('applies text color from style', (tester) async {
      await tester.pumpWidget(renderMaterialButton());

      final textFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.style!.color!.value ==
                style.color.getValue(Brightness.dark).value,
      );

      expect(textFinder, findsOneWidget);
    });

    testWidgets('applies dark theme background color from style',
        (tester) async {
      await tester.pumpWidget(renderMaterialButton(Brightness.dark));

      final containerFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Material &&
            widget.color.toString() ==
                style.backgroundColor.getValue(Brightness.dark).toString(),
      );

      expect(containerFinder, findsOneWidget);
    });

    testWidgets('applies dark theme text color from style', (tester) async {
      await tester.pumpWidget(renderMaterialButton(Brightness.dark));

      final textFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.style!.color.toString() ==
                style.color.getValue(Brightness.dark).toString(),
      );

      expect(textFinder, findsOneWidget);
    });

    testWidgets('renders an icon', (tester) async {
      await tester.pumpWidget(renderMaterialButton());

      final iconFinder = find.byWidgetPredicate(
        (widget) => widget is SvgPicture,
      );

      expect(iconFinder, findsOneWidget);
    });

    testWidgets('has layout flow aware padding', (tester) async {
      await tester.pumpWidget(DefaultAssetBundle(
        bundle: FakeAssetBundle(),
        child: MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                OAuthProviderButtonBase(
                  provider: provider,
                  auth: FakeAuth(),
                  label: 'Sign in with Fake provider',
                  loadingIndicator: const CircularProgressIndicator(),
                )
              ],
            ),
          ),
        ),
      ));

      expect(find.byType(LayoutFlowAwarePadding), findsOneWidget);
    });
  });
}
