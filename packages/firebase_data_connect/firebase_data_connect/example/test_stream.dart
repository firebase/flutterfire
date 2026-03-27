import 'dart:async';
import 'package:firebase_data_connect/firebase_data_connect.dart';

// Since the user didn't specify project info, we use dummy data that hits the emulator.
void main() async {
  print('Initializing test script for WebSocket emulator...');
  
  // Create connector config
  final connectorConfig = ConnectorConfig(
    'us-central1',
    'default',
    'default',
  );

  // We don't have a real Firebase app here, so we will manually instantiate 
  // the transport and connect.
  final options = DataConnectOptions(
    'demo-project',
    connectorConfig.location,
    connectorConfig.connector,
    connectorConfig.serviceId,
  );

  final transportOptions = TransportOptions('127.0.0.1', 9399, false);

  // We can use the core SDK type
  final transport = getTransport(
    transportOptions, 
    options,
    'test-app-id',
    CallerSDKType.core,
    null // no app check
  );

  final queryName = 'ListBlogs';
  
  // Execute via REST for comparison
  print('Trying to perform a standard unary executeQuery...');
  try {
    final response = await transport.invokeQuery<dynamic, dynamic>(
      queryName,
      (String s) => s, // dummy deserializer
      (dynamic v) => '{}', // dummy serializer
      null, 
      null
    );
    print('Unary Response: \${response.data}');
  } catch (e) {
    print('Unary Request Failed: \$e');
  }

  print('\\nInitiating Stream Subscribe for \$queryName...');
  final subscription = transport.invokeStreamQuery<dynamic, dynamic>(
    queryName,
    (String s) => s, 
    (dynamic v) => '{}', 
    null,
    null
  );

  subscription.listen((response) {
    print('Received Pushed Data: \${response.data}');
  }, onError: (err) {
    print('Stream Error: \$err');
  }, onDone: () {
    print('Stream Closed.');
  });
}
