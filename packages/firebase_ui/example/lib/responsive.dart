import 'package:firebase_ui/responsive.dart';
import 'package:firebase_ui_example/pages/responsive/grid_columns.dart';
import 'package:firebase_ui_example/pages/responsive/gutters.dart';
import 'package:flutter/material.dart';

import 'pages/responsive/body.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  void openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        cardTheme: const CardTheme(
          margin: EdgeInsets.zero,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Firebase UI Responsive'),
        ),
        body: Builder(
          builder: (context) => Body(
            child: Card(
              child: ListView(
                children: [
                  ListTile(
                    title: const Text('Body container'),
                    subtitle: const Text(
                      'Demonstrates how Body widget resizes '
                      'depending on available width',
                    ),
                    onTap: () {
                      openPage(context, const BodyExamplePage());
                    },
                  ),
                  ListTile(
                    title: const Text('Grid columns'),
                    subtitle: const Text(
                      'Demonstrats how grid columns count and sizes '
                      'change depending on available width',
                    ),
                    onTap: () {
                      openPage(context, const GridColumnsExamplePage());
                    },
                  ),
                  ListTile(
                    title: const Text('Gutters example'),
                    subtitle: const Text(
                      'Demonstrates how to use Row with Expanded '
                      'and facilitate the gutter width to match the grid',
                    ),
                    onTap: () {
                      openPage(context, const GuttersExamplePage());
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
