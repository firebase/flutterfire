import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:firebase_ml/firebase_ml.dart';

void main() {
  runApp(MyApp());
}

/// Widget with a future function that initiates actions from FirebaseML
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _pluginOutput = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String pluginOutput;
    try {
      pluginOutput = await FirebaseML.doSomething;
    } on PlatformException {
      pluginOutput = 'Failed to get plugin working.';
    }
    if (!mounted) return;

    setState(() {
      _pluginOutput = pluginOutput;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Plugin output: $_pluginOutput\n'),
        ),
      ),
    );
  }
}
