import 'package:firebase_ui/responsive.dart';
import 'package:firebase_ui_example/responsive.dart';
import 'package:firebase_ui_example/widgets/example_tab_bar.dart';
import 'package:flutter/material.dart';

class GridColumnsExamplePage extends StatelessWidget {
  const GridColumnsExamplePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: ExampleTabBar(title: 'Grid columns example'),
      body: Body(
        child: SizedBox.expand(
          child: _Content(),
        ),
      ),
    );
  }
}

class _Content extends StatefulWidget {
  const _Content({Key? key}) : super(key: key);

  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  late MediaQueryData mq;
  late int colsCount = 1;

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context);

    if (mq.maxColsCount < colsCount) {
      colsCount = mq.maxColsCount;
    }

    return Column(
      children: [
        Slider(
          value: colsCount.toDouble(),
          min: 1,
          max: mq.maxColsCount.toDouble(),
          onChanged: (v) {
            setState(() {
              colsCount = v.toInt();
            });
          },
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                color: Theme.of(context).primaryColor,
                height: double.infinity,
                width: mq.widthFor(cols: colsCount),
              ),
              const ResponsiveGridOverlay(enabled: true),
            ],
          ),
        ),
      ],
    );
  }
}
