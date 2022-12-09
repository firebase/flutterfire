// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pedantic/pedantic.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MetricHttpClient extends BaseClient {
  _MetricHttpClient(this._inner);

  final Client _inner;

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    // Custom network monitoring is not supported for web.
    // https://firebase.google.com/docs/perf-mon/custom-network-traces?platform=android
    final HttpMetric metric = FirebasePerformance.instance
        .newHttpMetric(request.url.toString(), HttpMethod.Get);

    metric.requestPayloadSize = request.contentLength;
    await metric.start();

    StreamedResponse response;
    try {
      response = await _inner.send(request);
      print(
        'Called ${request.url} with custom monitoring, response code: ${response.statusCode}',
      );

      metric.responseContentType = 'text/html';
      metric.httpResponseCode = response.statusCode;
      metric.responsePayloadSize = response.contentLength;

      metric.putAttribute('score', '15');
      metric.putAttribute('to_be_removed', 'should_not_be_logged');
    } finally {
      metric.removeAttribute('to_be_removed');
      await metric.stop();
    }

    final attributes = metric.getAttributes();

    print('Http metric attributes: $attributes.');

    String? score = metric.getAttribute('score');
    print('Http metric score attribute value: $score');

    return response;
  }
}

class _MyAppState extends State<MyApp> {
  FirebasePerformance _performance = FirebasePerformance.instance;
  bool _isPerformanceCollectionEnabled = false;
  String _performanceCollectionMessage =
      'Unknown status of performance collection.';
  bool _trace1HasRan = false;
  bool _trace2HasRan = false;
  bool _customHttpMetricHasRan = false;

  @override
  void initState() {
    super.initState();
    _togglePerformanceCollection();
  }

  Future<void> _togglePerformanceCollection() async {
    // No-op for web.
    await _performance
        .setPerformanceCollectionEnabled(!_isPerformanceCollectionEnabled);

    // Always true for web.
    final bool isEnabled = await _performance.isPerformanceCollectionEnabled();
    setState(() {
      _isPerformanceCollectionEnabled = isEnabled;
      _performanceCollectionMessage = _isPerformanceCollectionEnabled
          ? 'Performance collection is enabled.'
          : 'Performance collection is disabled.';
    });
  }

  Future<void> _testTrace1() async {
    setState(() {
      _trace1HasRan = false;
    });

    final Trace trace = _performance.newTrace('test_trace_3');
    await trace.start();
    trace.putAttribute('favorite_color', 'blue');
    trace.putAttribute('to_be_removed', 'should_not_be_logged');

    trace.incrementMetric('sum', 200);
    trace.incrementMetric('total', 342);

    trace.removeAttribute('to_be_removed');
    await trace.stop();

    final sum = trace.getMetric('sum');
    print('test_trace_1 sum value: $sum');

    final attributes = trace.getAttributes();
    print('test_trace_1 attributes: $attributes');

    final favoriteColor = trace.getAttribute('favorite_color');
    print('test_trace_1 favorite_color: $favoriteColor');

    setState(() {
      _trace1HasRan = true;
    });
  }

  Future<void> _testTrace2() async {
    setState(() {
      _trace2HasRan = false;
    });

    final Trace trace = FirebasePerformance.instance.newTrace('test_trace_2');
    await trace.start();

    trace.setMetric('sum', 333);
    trace.setMetric('sum_2', 895);
    await trace.stop();

    final sum2 = trace.getMetric('sum');
    print('test_trace_2 sum value: $sum2');

    setState(() {
      _trace2HasRan = true;
    });
  }

  Future<void> _testCustomHttpMetric() async {
    setState(() {
      _customHttpMetricHasRan = false;
    });

    final _MetricHttpClient metricHttpClient = _MetricHttpClient(Client());

    final Request request = Request(
      'SEND',
      Uri.parse('https://www.bbc.co.uk'),
    );

    unawaited(metricHttpClient.send(request));

    setState(() {
      _customHttpMetricHasRan = true;
    });
  }

  Future<void> _testAutomaticHttpMetric() async {
    Response response = await get(Uri.parse('https://www.facebook.com'));
    print('Called facebook, response code: ${response.statusCode}');
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(color: Colors.lightGreenAccent, fontSize: 25);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Firebase Performance Example'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Text(_performanceCollectionMessage),
              ElevatedButton(
                onPressed: _togglePerformanceCollection,
                child: const Text('Toggle Data Collection'),
              ),
              ElevatedButton(
                onPressed: _testTrace1,
                child: const Text('Run Trace One'),
              ),
              Text(
                _trace1HasRan ? 'Trace Ran!' : '',
                style: textStyle,
              ),
              ElevatedButton(
                onPressed: _testTrace2,
                child: const Text('Run Trace Two'),
              ),
              Text(
                _trace2HasRan ? 'Trace Ran!' : '',
                style: textStyle,
              ),
              ElevatedButton(
                onPressed: _testCustomHttpMetric,
                child: const Text('Run Custom HttpMetric'),
              ),
              Text(
                _customHttpMetricHasRan ? 'Custom HttpMetric Ran!' : '',
                style: textStyle,
              ),
              ElevatedButton(
                onPressed: _testAutomaticHttpMetric,
                child: const Text('Run Automatic HttpMetric'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
