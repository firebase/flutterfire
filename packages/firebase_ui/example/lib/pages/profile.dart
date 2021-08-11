import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_example/widgets/user_field_tile.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    final u = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User profile'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              children: [
                UserFieldTile(field: 'UID', value: u.uid),
                UserFieldTile(field: 'Display name', value: u.displayName),
                UserFieldTile(
                  field: 'Email',
                  value: u.email,
                  trailing: const EmailVerificationButton(),
                ),
                UserFieldTile(
                  field: 'Phone number',
                  value: u.phoneNumber,
                  trailing: u.phoneNumber == null
                      ? IconButton(
                          icon: const Icon(Icons.warning),
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const PhoneAuthFlow(
                                  authMethod: AuthMethod.link,
                                ),
                              ),
                            );

                            setState(() {});
                          })
                      : const VerifiedBadge(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.currentUser!.delete();
                  },
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateColor.resolveWith((states) => Colors.red),
                    overlayColor: MaterialStateColor.resolveWith(
                        (states) => Colors.red.withAlpha(20)),
                  ),
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete account'),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.logout_outlined),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  },
                  label: const Text('Sign out'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
