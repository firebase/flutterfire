// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: do_not_use_environment

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

const kWebRecaptchaSiteKey = '6Lemcn0dAAAAABLkf6aiiHvpGD6x-zF3nOSDU2M8';

// Windows: create a debug token in the Firebase Console
// (App Check > Apps > Manage debug tokens), then paste it here
// or set the APP_CHECK_DEBUG_TOKEN environment variable.
const kWindowsDebugToken = String.fromEnvironment(
  'APP_CHECK_DEBUG_TOKEN',
  // ignore: avoid_redundant_argument_values
  defaultValue: '',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Activate app check after initialization, but before
  // usage of any Firebase services.
  await FirebaseAppCheck.instance.activate(
    providerWeb: kDebugMode
        ? WebDebugProvider()
        : ReCaptchaV3Provider(kWebRecaptchaSiteKey),
    providerAndroid: const AndroidDebugProvider(),
    providerApple: const AppleDebugProvider(),
    // On Windows, only the debug provider is available.
    // You must supply a debug token — the desktop C++ SDK does not
    // auto-generate one. Create one in the Firebase Console under
    // App Check > Apps > Manage debug tokens, then either:
    //   - pass it via --dart-define=APP_CHECK_DEBUG_TOKEN=<token>
    //   - or set the APP_CHECK_DEBUG_TOKEN environment variable
    providerWindows: WindowsDebugProvider(
      debugToken: kWindowsDebugToken.isNotEmpty ? kWindowsDebugToken : null,
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String title = 'Firebase App Check';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase App Check',
      home: FirebaseAppCheckExample(title: title),
    );
  }
}

class FirebaseAppCheckExample extends StatefulWidget {
  FirebaseAppCheckExample({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  _FirebaseAppCheck createState() => _FirebaseAppCheck();
}

class _FirebaseAppCheck extends State<FirebaseAppCheckExample> {
  final appCheck = FirebaseAppCheck.instance;
  String _message = '';
  String _eventToken = 'not yet';

  @override
  void initState() {
    appCheck.onTokenChange.listen(setEventToken);
    super.initState();
  }

  void setMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  void setEventToken(String? token) {
    setState(() {
      _eventToken = token ?? 'not yet';
    });
  }

  Future<void> _activate({
    AndroidAppCheckProvider? android,
    AppleAppCheckProvider? apple,
    WindowsAppCheckProvider? windows,
  }) async {
    try {
      await appCheck.activate(
        providerAndroid: android ?? const AndroidPlayIntegrityProvider(),
        providerApple: apple ?? const AppleDeviceCheckProvider(),
        providerWeb: ReCaptchaV3Provider(kWebRecaptchaSiteKey),
        providerWindows: windows ?? const WindowsDebugProvider(),
      );
      final providerName = windows?.runtimeType.toString() ??
          apple?.runtimeType.toString() ??
          android?.runtimeType.toString() ??
          'default';
      setMessage('Activated with $providerName');
    } catch (e) {
      setMessage('activate error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Providers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _activate(
                android: const AndroidDebugProvider(),
                apple: const AppleDebugProvider(),
                windows: WindowsDebugProvider(
                  debugToken: kWindowsDebugToken.isNotEmpty
                      ? kWindowsDebugToken
                      : null,
                ),
              ),
              child: const Text('activate(Debug)'),
            ),
            ElevatedButton(
              onPressed: () => _activate(
                android: const AndroidPlayIntegrityProvider(),
                apple: const AppleDeviceCheckProvider(),
              ),
              child: const Text('activate(PlayIntegrity / DeviceCheck)'),
            ),
            if (!kIsWeb)
              ElevatedButton(
                onPressed: () => _activate(
                  apple: const AppleAppAttestProvider(),
                ),
                child: const Text('activate(AppAttest)'),
              ),
            if (!kIsWeb)
              ElevatedButton(
                onPressed: () => _activate(
                  apple: const AppleAppAttestWithDeviceCheckFallbackProvider(),
                ),
                child: const Text(
                  'activate(AppAttest + DeviceCheck fallback)',
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                try {
                  final token = await appCheck.getToken(true);
                  setMessage('Token: ${token?.substring(0, 20)}...');
                } catch (e) {
                  setMessage('getToken error: $e');
                }
              },
              child: const Text('getToken(forceRefresh: true)'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final token = await appCheck.getLimitedUseToken();
                  setMessage(
                    'Limited use token: ${token.substring(0, 20)}...',
                  );
                } catch (e) {
                  setMessage('getLimitedUseToken error: $e');
                }
              },
              child: const Text('getLimitedUseToken()'),
            ),
            ElevatedButton(
              onPressed: () async {
                await appCheck.setTokenAutoRefreshEnabled(true);
                setMessage('Token auto-refresh enabled');
              },
              child: const Text('setTokenAutoRefreshEnabled(true)'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final result = await FirebaseFirestore.instance
                      .collection('flutter-tests')
                      .limit(1)
                      .get();
                  setMessage(
                    result.docs.isNotEmpty
                        ? 'Firestore: Document found'
                        : 'Firestore: No documents',
                  );
                } catch (e) {
                  setMessage('Firestore error: $e');
                }
              },
              child: const Text('Test Firestore with App Check'),
            ),
            const SizedBox(height: 20),
            Text(
              _message,
              style: const TextStyle(
                color: Color.fromRGBO(47, 79, 79, 1),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Token from onTokenChange: $_eventToken',
              style: const TextStyle(
                color: Color.fromRGBO(128, 0, 128, 1),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
