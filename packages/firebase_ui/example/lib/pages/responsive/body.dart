import 'package:firebase_ui/responsive.dart';
import 'package:firebase_ui_example/widgets/example_tab_bar.dart';
import 'package:flutter/material.dart';

class BodyExamplePage extends StatelessWidget {
  const BodyExamplePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ExampleTabBar(title: 'Body() example'),
      body: Body(
        child: SizedBox.expand(
          child: Container(color: Colors.blue),
        ),
      ),
    );
  }
}
