import 'package:firebase_ui/responsive.dart';
import 'package:flutter/material.dart';

class DeviceIndicator extends StatelessWidget {
  const DeviceIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceType = MediaQuery.of(context).deviceType;

    switch (deviceType) {
      case DeviceType.phone:
        return const Icon(Icons.phone_android_outlined);
      case DeviceType.phablet:
        return const Icon(Icons.tablet_android);
      case DeviceType.tablet:
        return const Icon(Icons.tablet_mac_outlined);
      case DeviceType.laptop:
        return const Icon(Icons.laptop_chromebook_outlined);
      case DeviceType.desktop:
        return const Icon(Icons.desktop_mac);
    }
  }
}
