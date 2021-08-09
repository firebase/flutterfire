import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_ui/auth.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(FirebaseAuthUIExample());
}

class FirebaseAuthUIExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        snapshot.requireData;

        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const Home(),
        );
      },
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.userChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          Widget? child;

          if (user == null) {
            child = AuthFlowBuilder<PhoneVerificationController>(
              auth: FirebaseAuth.instance,
              flow: PhoneVerificationAuthFlow(),
              onComplete: (credential) async {
                await FirebaseAuth.instance.signInWithCredential(credential);
              },
              builder: (context, state, flow) {
                if (state is UninitializedAuthState) {
                  return TextField(onSubmitted: flow.acceptPhoneNumber);
                }

                if (state is SMSCodeSent) {
                  return TextField(onSubmitted: flow.verifySMSCode);
                }

                return Text('Unknown auth flow state $state');
              },
            );
          } else {
            child = const Profile();
          }

          return child;
        },
      ),
    );
  }
}

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('Hello, ${FirebaseAuth.instance.currentUser!.displayName}'),
    );
  }
}
