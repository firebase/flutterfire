import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Requests & displays the current user permissions for this device.
class Permissions extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Permissions();
}

class _Permissions extends State<Permissions> {
  bool _requested = false;
  bool _fetching = false;
  late NotificationSettings _settings;

  Future<void> requestPermissions() async {
    setState(() {
      _fetching = true;
    });

    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      announcement: true,
      carPlay: true,
      criticalAlert: true,
    );

    setState(() {
      _requested = true;
      _fetching = false;
      _settings = settings;
    });
  }

  Widget row(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$title:', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_fetching) {
      return const CircularProgressIndicator();
    }

    if (!_requested) {
      return ElevatedButton(
          onPressed: requestPermissions,
          child: const Text('Request Permissions'));
    }

    return Column(children: [
      row('Authorization Status',
          statusMap[_settings.authorizationStatus] ?? 'N/A'),
      if (defaultTargetPlatform == TargetPlatform.iOS) ...[
        row('Alert', settingsMap[_settings.alert] ?? 'N/A'),
        row('Announcement', settingsMap[_settings.announcement] ?? 'N/A'),
        row('Badge', settingsMap[_settings.badge] ?? 'N/A'),
        row('Car Play', settingsMap[_settings.carPlay] ?? 'N/A'),
        row('Lock Screen', settingsMap[_settings.lockScreen] ?? 'N/A'),
        row('Notification Center',
            settingsMap[_settings.notificationCenter] ?? 'N/A'),
        row('Show Previews', previewMap[_settings.showPreviews] ?? 'N/A'),
        row('Sound', settingsMap[_settings.sound] ?? 'N/A'),
      ],
      ElevatedButton(
          onPressed: () => {}, child: const Text('Reload Permissions')),
    ]);
  }
}

/// Maps a [AuthorizationStatus] to a string value.
const statusMap = {
  AuthorizationStatus.authorized: 'Authorized',
  AuthorizationStatus.denied: 'Denied',
  AuthorizationStatus.notDetermined: 'Not Determined',
  AuthorizationStatus.provisional: 'Provisional',
};

/// Maps a [AppleNotificationSetting] to a string value.
const settingsMap = {
  AppleNotificationSetting.disabled: 'Disabled',
  AppleNotificationSetting.enabled: 'Enabled',
  AppleNotificationSetting.notSupported: 'Not Supported',
};

/// Maps a [AppleShowPreviewSetting] to a string value.
const previewMap = {
  AppleShowPreviewSetting.always: 'Always',
  AppleShowPreviewSetting.never: 'Never',
  AppleShowPreviewSetting.notSupported: 'Not Supported',
  AppleShowPreviewSetting.whenAuthenticated: 'Only When Authenticated',
};
