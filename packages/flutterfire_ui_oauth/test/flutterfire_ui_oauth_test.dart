import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterfire_ui_oauth/flutterfire_ui_oauth.dart';
import 'package:flutterfire_ui_oauth_google/flutterfire_ui_google_oauth.dart';

class FakeAssetBundle extends Fake implements AssetBundle {
  final String svgStr = '''<svg viewBox="0 0 10 10"></svg>''';

  @override
  Future<String> loadString(String key, {bool cache = true}) async => svgStr;
}

void main() {
  int tapCount = 0;

  final style = GoogleProviderButtonStyle();
  Completer<void> completer = Completer();
  late Widget button;

  Future<void> onTap() async {
    await completer.future;
    tapCount++;
  }

  setUp(() {
    tapCount = 0;
    completer = Completer();
  });

  Widget renderMaterialButton([Brightness brightness = Brightness.dark]) {
    button = OAuthProviderButton(
      style: style,
      label: 'Sign in with Google',
      onTap: onTap,
      loadingIndicator: const CircularProgressIndicator(),
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

      final containerFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Material &&
            widget.color.toString() ==
                style.backgroundColor.getValue(Brightness.light).toString(),
      );

      expect(containerFinder, findsOneWidget);
    });

    testWidgets('applies text color from style', (tester) async {
      await tester.pumpWidget(renderMaterialButton());

      final textFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.style!.color.toString() ==
                style.color.getValue(Brightness.light).toString(),
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

    testWidgets(
      'renders a loading indicator until onTap future is resolved',
      (tester) async {
        await tester.pumpWidget(renderMaterialButton());

        final loadingIndicatorFinder = find.byWidgetPredicate(
          (widget) => widget is CircularProgressIndicator,
        );

        expect(loadingIndicatorFinder, findsNothing);

        await tester.tap(find.byWidget(button));
        await tester.pump();

        expect(loadingIndicatorFinder, findsOneWidget);
      },
    );
  });
}
