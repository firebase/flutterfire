import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

import '../widgets/internal/universal_page_route.dart';

Future<void> showForgotPasswordScreen(BuildContext context) async {
  final route = createPageRoute(
    context: context,
    builder: (context) => const ForgotPasswordScreen(),
  );

  await Navigator.of(context).push(route);
}
