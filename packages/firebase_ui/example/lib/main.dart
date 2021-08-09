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
        if (!snapshot.hasData) {
          return Container();
        }

        return MaterialApp(
          title: 'Firebase UI demo',
          theme: ThemeData(
            brightness: Brightness.dark,
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(),
            ),
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
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const Profile();
        }

        return const Login();
      },
    );
  }
}

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  AuthMethod method = AuthMethod.signIn;
  late final ctrl = TabController(length: 2, vsync: this)
    ..addListener(() {
      setState(() {
        method = AuthMethod.values.elementAt(ctrl.index);
      });
    });

  @override
  Widget build(BuildContext context) {
    final tabs = TabBar(
      controller: ctrl,
      tabs: const [
        Tab(child: Text('Sign in')),
        Tab(child: Text('Sign up')),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase UI auth demo'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IntrinsicHeight(
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  tabs,
                  Expanded(
                    child: Column(
                      children: [
                        AuthFlowBuilder(
                          flow: EmailFlow(
                            auth: FirebaseAuth.instance,
                            method: method,
                          ),
                          listener: (oldState, newState) {
                            if (newState is AuthFailed) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    newState.exception.toString(),
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: SignInForm(),
                          ),
                        ),
                        const Text('Other sign in options'),
                        Padding(
                          padding: const EdgeInsets.all(16).copyWith(top: 0),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const PhoneAuthFlow(
                                          authMethod: AuthMethod.signIn),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.phone),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SignInForm extends StatefulWidget {
  const SignInForm({Key? key}) : super(key: key);

  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  String chooseButtonLabel() {
    final ctrl = AuthController.of(context);

    switch (ctrl.method) {
      case AuthMethod.signIn:
        return 'Sing in';
      case AuthMethod.signUp:
        return 'Sign up';
      case AuthMethod.link:
        return 'Next';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = AuthController.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: emailCtrl,
          decoration: const InputDecoration(labelText: 'Email'),
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordCtrl,
          decoration: const InputDecoration(labelText: 'Password'),
          autofocus: true,
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            (ctrl as EmailFlowController).setEmailAndPassword(
              emailCtrl.text,
              passwordCtrl.text,
            );
          },
          child: Text(chooseButtonLabel()),
        ),
      ],
    );
  }
}

class PhoneAuthFlow extends StatelessWidget {
  final AuthMethod authMethod;

  const PhoneAuthFlow({Key? key, required this.authMethod}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify phone number'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: AuthFlowBuilder<PhoneVerificationController>(
            flow: PhoneVerificationAuthFlow(
              auth: FirebaseAuth.instance,
              method: authMethod,
            ),
            listener: (_, newState) {
              if (newState is SignedIn) {
                Navigator.of(context).pop();
              }
            },
            builder: (context, state, ctrl, _) {
              if (state is AwatingPhoneNumber) {
                return TextField(
                  decoration: const InputDecoration(labelText: 'Phone number'),
                  onSubmitted: ctrl.acceptPhoneNumber,
                  autofocus: true,
                  keyboardType: TextInputType.phone,
                );
              }

              if (state is SMSCodeRequested ||
                  state is CredentialReceived ||
                  state is PhoneVerified) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is SMSCodeSent) {
                return TextField(
                  decoration: const InputDecoration(labelText: 'SMS Code'),
                  onSubmitted: ctrl.verifySMSCode,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                );
              }

              return Text('Unknown auth flow state $state');
            },
          ),
        ),
      ),
    );
  }
}

class UserFieldTile extends StatelessWidget {
  final String field;
  final String? value;
  final Widget? trailing;

  const UserFieldTile({
    Key? key,
    required this.field,
    required this.value,
    this.trailing,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(field),
      subtitle: Text(value ?? 'unknown'),
      trailing: trailing,
    );
  }
}

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

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
                  trailing: u.emailVerified
                      ? const Icon(Icons.verified)
                      : IconButton(
                          icon: Icon(Icons.warning),
                          onPressed: () {
                            // TODO(@lesnitsky): implement
                          },
                        ),
                ),
                UserFieldTile(field: 'Phone number', value: u.phoneNumber),
              ],
            ),
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            label: const Text('Sign out'),
          )
        ],
      ),
    );
  }
}
