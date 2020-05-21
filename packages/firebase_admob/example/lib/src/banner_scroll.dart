import 'package:flutter/material.dart';
import '../src/banner.dart';

void main() => runApp(BannerScroll());

class BannerScroll extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'banner ad in scroll view',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BannerScrollView(),
    );
  }
}

class BannerScrollView extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<BannerScrollView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
              floating: true,
              pinned: true,
              snap: true,
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  tooltip: 'button',
                  onPressed: () { },
                ),
              ]
          ),
          SliverFillRemaining(
            child: AdBanner(),
          ),
        ],
      ),
    );
  }
}