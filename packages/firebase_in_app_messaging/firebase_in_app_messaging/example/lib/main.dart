// ignore_for_file: require_trailing_commas
// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseInAppMessaging fiam = FirebaseInAppMessaging.instance;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('In-App Messaging example'),
        ),
        body: Builder(
          builder: (BuildContext context) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  AnalyticsEventExample(),
                  ProgrammaticTriggersExample(),
                  MessageEventsExample(),
                  CustomDisplayExample(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ProgrammaticTriggersExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            const Text(
              'Programmatic Trigger',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Manually trigger events programmatically '),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await MyApp.fiam.triggerEvent('awesome_event');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Triggering event: awesome_event'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text(
                'Programmatic Triggers'.toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MessageEventsExample extends StatefulWidget {
  @override
  State<MessageEventsExample> createState() => _MessageEventsExampleState();
}

class _MessageEventsExampleState extends State<MessageEventsExample> {
  final List<StreamSubscription<Object>> _subscriptions =
      <StreamSubscription<Object>>[];
  String _lastEvent = 'No message event yet';

  @override
  void initState() {
    super.initState();

    _subscriptions.addAll(<StreamSubscription<Object>>[
      MyApp.fiam.onMessageClicked.listen((InAppMessagingClickEvent event) {
        _log('clicked ${event.campaignMetadata.campaignName}, '
            'action url: ${event.action.actionUrl}');
      }),
      MyApp.fiam.onMessageImpression
          .listen((InAppMessagingImpressionEvent event) {
        _log('impression for ${event.campaignMetadata.campaignName}');
      }),
      MyApp.fiam.onMessageDismissed.listen((InAppMessagingDismissEvent event) {
        _log('dismissed ${event.campaignMetadata.campaignName} '
            '(${event.dismissType.name})');
      }),
      MyApp.fiam.onMessageDisplayError
          .listen((InAppMessagingDisplayErrorEvent event) {
        _log('display error for ${event.campaignMetadata.campaignName}: '
            '${event.errorMessage}');
      }),
    ]);
  }

  @override
  void dispose() {
    for (final StreamSubscription<Object> subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  void _log(String message) {
    if (!mounted) return;
    setState(() {
      _lastEvent = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            const Text(
              'Message events',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Last event received from the campaign'),
            const SizedBox(height: 8),
            Text(_lastEvent, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class CustomDisplayExample extends StatefulWidget {
  @override
  State<CustomDisplayExample> createState() => _CustomDisplayExampleState();
}

class _CustomDisplayExampleState extends State<CustomDisplayExample> {
  StreamSubscription<InAppMessage>? _subscription;
  bool _customDisplayEnabled = false;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _toggle(bool enabled) async {
    await _subscription?.cancel();
    _subscription = null;
    if (enabled) {
      _subscription = MyApp.fiam.onMessageDisplay.listen(_show);
    }
    await MyApp.fiam.setCustomDisplayEnabled(enabled);
    if (mounted) {
      setState(() {
        _customDisplayEnabled = enabled;
      });
    }
  }

  Future<void> _show(InAppMessage message) async {
    if (!mounted) return;
    await message.impress();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final InAppMessageAction? primary =
            message.primaryAction ?? message.action;
        return AlertDialog(
          title: Text(
              message.title?.text ?? message.campaignMetadata.campaignName),
          content: Text(message.body?.text ?? 'Custom Flutter in-app message'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await message.dismiss();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Dismiss'),
            ),
            if (primary != null)
              FilledButton(
                onPressed: () async {
                  await message.click(primary);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Action URL: ${primary.actionUrl ?? '(none)'}',
                        ),
                      ),
                    );
                  }
                },
                child: Text(primary.buttonText ?? 'Continue'),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            const Text(
              'Custom Flutter display',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'When enabled, campaigns are rendered with Flutter widgets instead of native templates.',
              textAlign: TextAlign.center,
            ),
            SwitchListTile(
              title: const Text('Use custom display'),
              value: _customDisplayEnabled,
              onChanged: _toggle,
            ),
          ],
        ),
      ),
    );
  }
}

class AnalyticsEventExample extends StatelessWidget {
  Future<void> _sendAnalyticsEvent() async {
    await MyApp.analytics.logEvent(
      name: 'awesome_event',
      parameters: <String, Object>{
        //'id': 1, // not required?
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            const Text(
              'Log an analytics event',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Trigger an analytics event'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                _sendAnalyticsEvent();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Firing analytics event: awesome_event'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text(
                'Log event'.toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
