import 'package:flutter/material.dart';
import 'package:flutterfire_ui_example/startup.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/main',
  routes: [
    GoRoute(
      path: '/main',
      name: 'main',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const StartUpView(),
      ),
    ),
  ],
);
