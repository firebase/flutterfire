import 'dart:async';
import 'package:firebase_data_connect/src/common/common_library.dart';
import 'package:firebase_data_connect/src/network/rest_library.dart';

void main() async {
  print('Initializing test script for WebSocket emulator...');
  
  final options = DataConnectOptions(
    'demo-project',
    'us-central1',
    'default',
    'default',
  );

  final transportOptions = TransportOptions('127.0.0.1', 9399, false);

  final transport = getTransport(
    transportOptions, 
    options,
    'test-app-id',
    CallerSDKType.core,
    null
  );

  final queryName = 'ListBlogs';
  
  print('\nInitiating Stream Subscribe for $queryName...');
  final subscription = transport.invokeStreamQuery<dynamic, dynamic>(
    queryName,
    (String s) => s, 
    (dynamic v) => '{}', 
    null,
    null
  );

  subscription.listen((response) {
    print('Received Pushed Data: ${response.data}');
  }, onError: (err) {
    print('Stream Error: $err');
  }, onDone: () {
    print('Stream Closed.');
  });

  await Future.delayed(Duration(seconds: 10));
}
