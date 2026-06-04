// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: do_not_use_environment

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

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
    providerWeb: kDebugMode ? WebDebugProvider() : WebReCaptchaProvider(),
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
  late final TextEditingController _webSiteKeyController;
  StreamSubscription<String?>? _tokenSubscription;

  @override
  void initState() {
    _webSiteKeyController = TextEditingController();
    appCheck.onTokenChange.listen(setEventToken);
    super.initState();
  }

  @override
  void dispose() {
    _webSiteKeyController.dispose();
    _tokenSubscription?.cancel();
    super.dispose();
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
    WebProvider? web,
    WindowsAppCheckProvider? windows,
  }) async {
    try {
      await appCheck.activate(
        providerAndroid: android ?? const AndroidPlayIntegrityProvider(),
        providerApple: apple ?? const AppleDeviceCheckProvider(),
        providerWeb: web ?? const WebReCaptchaProvider(),
        providerWindows: windows ?? const WindowsDebugProvider(),
      );
      await _tokenSubscription?.cancel();
      _tokenSubscription = appCheck.onTokenChange.listen(setEventToken);
      final providerName = windows?.runtimeType.toString() ??
          web?.runtimeType.toString() ??
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
            if (kIsWeb) ...[
              ElevatedButton(
                onPressed: () => _activate(
                  web: const WebReCaptchaProvider(),
                ),
                child: const Text('activate(Web reCAPTCHA from options)'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _activate(
                  web: ReCaptchaV3Provider(_webSiteKeyController.text),
                ),
                child: const Text('activate(Web reCAPTCHA v3)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _webSiteKeyController,
                decoration: const InputDecoration(
                  labelText: 'Web reCAPTCHA Site Key',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _activate(
                  web: ReCaptchaEnterpriseProvider(_webSiteKeyController.text),
                ),
                child: const Text('activate(Web reCAPTCHA Enterprise)'),
              ),
            ],
            if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) ...[
              ElevatedButton(
                onPressed: () => _activate(
                  android: const AndroidDebugProvider(),
                ),
                child: const Text('activate(Android Debug)'),
              ),
              ElevatedButton(
                onPressed: () => _activate(
                  android: const AndroidPlayIntegrityProvider(),
                ),
                child: const Text('activate(Android Play Integrity)'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _activate(
                  android: const AndroidReCaptchaProvider(),
                ),
                child: const Text('activate(Android reCAPTCHA)'),
              ),
            ],
            if (!kIsWeb &&
                (defaultTargetPlatform == TargetPlatform.iOS ||
                    defaultTargetPlatform == TargetPlatform.macOS)) ...[
              ElevatedButton(
                onPressed: () => _activate(
                  apple: const AppleDebugProvider(),
                ),
                child: const Text('activate(Apple Debug)'),
              ),
              ElevatedButton(
                onPressed: () => _activate(
                  apple: const AppleDeviceCheckProvider(),
                ),
                child: const Text('activate(Apple DeviceCheck)'),
              ),
              ElevatedButton(
                onPressed: () => _activate(
                  apple: const AppleAppAttestProvider(),
                ),
                child: const Text('activate(Apple AppAttest)'),
              ),
              ElevatedButton(
                onPressed: () => _activate(
                  apple: const AppleAppAttestWithDeviceCheckFallbackProvider(),
                ),
                child: const Text(
                  'activate(Apple AppAttest + DeviceCheck fallback)',
                ),
              ),
              if (defaultTargetPlatform == TargetPlatform.iOS) ...[
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _activate(
                    apple: const AppleReCaptchaProvider(),
                  ),
                  child: const Text('activate(Apple reCAPTCHA)'),
                ),
              ],
            ],
            if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) ...[
              ElevatedButton(
                onPressed: () => _activate(
                  windows: WindowsDebugProvider(
                    debugToken: kWindowsDebugToken.isNotEmpty
                        ? kWindowsDebugToken
                        : null,
                  ),
                ),
                child: const Text('activate(Windows Debug)'),
              ),
            ],
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
            SelectableText(
              _message,
              style: const TextStyle(
                color: Color.fromRGBO(47, 79, 79, 1),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            SelectableText(
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
