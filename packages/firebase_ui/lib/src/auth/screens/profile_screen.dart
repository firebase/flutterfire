import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:firebase_ui/i10n.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui/auth.dart';

class ProfileScreen extends StatelessWidget {
  final FirebaseAuth? auth;
  final Color? avatarPlaceholderColor;
  final ShapeBorder? avatarShape;
  final double? avatarSize;

  const ProfileScreen({
    Key? key,
    this.auth,
    this.avatarPlaceholderColor,
    this.avatarShape,
    this.avatarSize,
  }) : super(key: key);

  void _logout() {
    (auth ?? FirebaseAuth.instance).signOut();
  }

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.profile),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              child: UserAvatar(
                auth: auth,
                placeholderColor: avatarPlaceholderColor,
                shape: avatarShape,
                size: avatarSize,
              ),
            ),
            const SizedBox(height: 16),
            Align(child: EditableUserDisplayName(auth: auth)),
          ],
        ),
      ),
    );
  }
}
