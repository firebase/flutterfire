// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class TabsPage extends StatefulWidget {
  TabsPage(this.observer, {Key? key}) : super(key: key);

  final FirebaseAnalyticsObserver observer;

  static const String routeName = '/tab';

  @override
  State<StatefulWidget> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage>
    with
        SingleTickerProviderStateMixin,
        // ignore: prefer_mixin
        RouteAware {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  late final TabController _controller = TabController(
    vsync: this,
    length: tabs.length,
    initialIndex: selectedIndex,
  );
  int selectedIndex = 0;

  final List<Tab> tabs = <Tab>[
    const Tab(text: 'LEFT'),
    const Tab(text: 'RIGHT'),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.observer.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    widget.observer.unsubscribe(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        if (selectedIndex != _controller.index) {
          selectedIndex = _controller.index;
          _sendCurrentTabToAnalytics();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _controller,
          tabs: tabs,
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: tabs.map((Tab tab) {
          return Center(child: Text(tab.text!));
        }).toList(),
      ),
    );
  }

  @override
  void didPush() {
    _sendCurrentTabToAnalytics();
  }

  @override
  void didPopNext() {
    _sendCurrentTabToAnalytics();
  }

  void _sendCurrentTabToAnalytics() {
    analytics.logScreenView(
      screenName: '${TabsPage.routeName}/tab$selectedIndex',
    );
  }
}
