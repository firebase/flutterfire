// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

import 'dart:async';

import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';

import 'package:firebase_performance/firebase_performance.dart';

void main() => runApp(const MyApp());

void myLog(String msg) {
  print('My Log: $msg');
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MetricHttpClient extends BaseClient {
  _MetricHttpClient(this._inner);

  final Client _inner;

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final HttpMetric metric = FirebasePerformance.instance
        .newHttpMetric(request.url.toString(), HttpMethod.Get);

    await metric.start();

    StreamedResponse response;
    try {
      response = await _inner.send(request);
      myLog(
          'Called ${request.url} with custom monitoring, response code: ${response.statusCode}');

      metric
        ..responsePayloadSize = response.contentLength
        ..responseContentType = response.headers['Content-Type']
        ..requestPayloadSize = request.contentLength
        ..httpResponseCode = response.statusCode;

      await metric.putAttribute('score', '15');
      await metric.putAttribute('to_be_removed', 'should_not_be_logged');
    } finally {
      await metric.removeAttribute('to_be_removed');
      await metric.stop();
    }

    unawaited(metric
        .getAttributes()
        .then((attributes) => myLog('Http metric attributes: $attributes')));

    String score = metric.getAttribute('score');
    myLog('Http metric score attribute value: $score');

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
    await _performance
        .setPerformanceCollectionEnabled(!_isPerformanceCollectionEnabled);

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

    final Trace trace = _performance.newTrace('test_trace_1');
    await trace.start();
    await trace.putAttribute('favorite_color', 'blue');
    await trace.putAttribute('to_be_removed', 'should_not_be_logged');

    for (int i = 0; i < 10; i++) {
      await trace.incrementMetric('sum', i);
    }

    await trace.removeAttribute('to_be_removed');
    await trace.stop();

    unawaited(trace
        .getMetric('sum')
        .then((sumValue) => myLog('test_trace_1 sum value: $sumValue')));
    unawaited(trace
        .getAttributes()
        .then((attributes) => myLog('test_trace_1 attributes: $attributes')));

    String favoriteColor = trace.getAttribute('favorite_color');
    myLog('test_trace_1 favorite_color: $favoriteColor');

    setState(() {
      _trace1HasRan = true;
    });
  }

  Future<void> _testTrace2() async {
    setState(() {
      _trace2HasRan = false;
    });

    final Trace trace = await FirebasePerformance.startTrace('test_trace_2');

    int sum = 0;
    for (int i = 0; i < 10000000; i++) {
      sum += i;
    }
    await trace.setMetric('sum', sum);
    await trace.stop();

    unawaited(trace
        .getMetric('sum')
        .then((sumValue) => myLog('test_trace_2 sum value: $sumValue')));

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
      Uri.parse('https://www.google.com'),
    );

    unawaited(metricHttpClient.send(request));

    setState(() {
      _customHttpMetricHasRan = true;
    });
  }

  Future<void> _testAutomaticHttpMetric() async {
    Response response = await get(Uri.parse('https://www.facebook.com'));
    myLog('Called facebook, response code: ${response.statusCode}');
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
