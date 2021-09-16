import 'package:firebase_ui/responsive.dart';
import 'package:firebase_ui_example/widgets/example_tab_bar.dart';
import 'package:flutter/material.dart';

class ResponsiveContainerExamplePage extends StatelessWidget {
  const ResponsiveContainerExamplePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gutterSize = MediaQuery.of(context).gutterSize;

    return Scaffold(
      appBar: const ExampleAppBar(title: 'ResponsiveContainer() demo'),
      body: Body(
        child: Padding(
          padding: EdgeInsets.only(top: gutterSize),
          child: Wrap(
            runSpacing: MediaQuery.of(context).gutterSize,
            spacing: MediaQuery.of(context).gutterSize,
            children: [
              ResponsiveContainer(
                colWidth: ColWidth(
                  phone: 4,
                  phablet: 4,
                  tablet: 6,
                  laptop: 6,
                  desktop: 6,
                ),
                child: const _Tile(color: Colors.blue),
              ),
              ResponsiveContainer(
                colWidth: ColWidth(
                  phone: 4,
                  phablet: 4,
                  tablet: 6,
                  laptop: 6,
                  desktop: 6,
                ),
                child: const _Tile(color: Colors.red),
              ),
              ResponsiveContainer(
                colWidth: ColWidth(
                  phone: 1,
                  phablet: 2,
                  tablet: 3,
                  laptop: 3,
                  desktop: 3,
                ),
                child: const _Tile(color: Colors.green),
              ),
              ResponsiveContainer(
                colWidth: ColWidth(
                  phone: 3,
                  phablet: 6,
                  tablet: 9,
                  laptop: 9,
                  desktop: 9,
                ),
                child: const _Tile(color: Colors.yellow),
              ),
              ResponsiveContainer(
                colWidth: ColWidth(
                  phone: 2,
                  phablet: 4,
                  tablet: 2,
                  laptop: 3,
                  desktop: 3,
                ),
                child: const _Tile(color: Colors.pink),
              ),
              ResponsiveContainer(
                colWidth: ColWidth(
                  phone: 2,
                  phablet: 4,
                  tablet: 3,
                  laptop: 3,
                  desktop: 3,
                ),
                child: const _Tile(color: Colors.purple),
              ),
              ResponsiveContainer(
                colWidth: ColWidth(
                  phone: 8,
                  phablet: 8,
                  tablet: 7,
                  laptop: 6,
                  desktop: 6,
                ),
                child: const _Tile(color: Colors.cyan),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final Color color;
  const _Tile({Key? key, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).colSize,
      color: color,
    );
  }
}
