import 'package:flutter/material.dart';

import 'device_indicator.dart';

class ExampleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const ExampleAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;

    return SizedBox(
      height: kToolbarHeight,
      child: Material(
        elevation: appBarTheme.elevation ?? 1,
        color: appBarTheme.backgroundColor ?? theme.primaryColor,
        child: Row(
          children: [
            const BackButton(color: Colors.white),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Theme(
                    data: theme.copyWith(iconTheme: theme.primaryIconTheme),
                    child: const DeviceIndicator(),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
