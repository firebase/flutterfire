// @dart=2.9

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e2e/e2e.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('buildUrl', (WidgetTester tester) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://cx4k7.app.goo.gl',
      link: Uri.parse('https://dynamic.link.example/helloworld'),
      androidParameters: AndroidParameters(
        packageName: 'io.flutter.plugins.firebasedynamiclinksexample',
        minimumVersion: 0,
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.google.FirebaseCppDynamicLinksTestApp.dev',
        minimumVersion: '0',
      ),
    );

    final Uri uri = await parameters.buildUrl();
    expect(
      uri.toString(),
      'https://cx4k7.app.goo.gl?amv=0&apn=io.flutter.plugins.firebasedynamiclinksexample&ibi=com.google.FirebaseCppDynamicLinksTestApp.dev&imv=0&link=https%3A%2F%2Fdynamic.link.example%2Fhelloworld',
    );
  });
}
