import 'package:flutter/material.dart';

class TestMaterialApp extends StatelessWidget {
  final Widget child;

  const TestMaterialApp({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }
}
