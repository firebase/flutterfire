import 'package:firebase_ui/responsive.dart';
import 'package:firebase_ui_example/widgets/example_tab_bar.dart';
import 'package:flutter/material.dart';

class GuttersExamplePage extends StatefulWidget {
  const GuttersExamplePage({Key? key}) : super(key: key);

  @override
  _GuttersExamplePageState createState() => _GuttersExamplePageState();
}

class _GuttersExamplePageState extends State<GuttersExamplePage> {
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Scaffold(
      appBar: const ExampleAppBar(title: 'Gutters example'),
      body: Body(
        child: ListView.separated(
          itemBuilder: (context, index) {
            return SizedBox(
              height: mq.colSize,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: mq.widthFor(cols: index + 1),
                    child: const Card(),
                  ),
                  const Gutter.vertical(),
                  const Expanded(child: Card()),
                ],
              ),
            );
          },
          separatorBuilder: (_, __) => const Gutter.horizontal(),
          itemCount: mq.maxColsCount - 1,
        ),
      ),
    );
  }
}
