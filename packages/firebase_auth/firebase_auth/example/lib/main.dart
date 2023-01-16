import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

FirebaseApp? firebaseApp;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Note: This line will make the sample work
  /*firebaseApp = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );*/
  // Note: This is not working
  firebaseApp = await Firebase.initializeApp(
    name: 'foo',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAuth.instance
      .authStateChanges()
      .listen((e) => {print('/// auth state on [DEFAULT] changed: ${e?.uid}')});
  final auth = FirebaseAuth.instanceFor(app: firebaseApp!);
  auth
      .authStateChanges()
      .listen((e) => {print('/// auth state on foo changed: ${e?.uid}')});

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  final _auth = FirebaseAuth.instanceFor(app: firebaseApp!);

  @override
  void initState() {
    super.initState();

    _auth.userChanges().listen((user) {
      print('/// Firebase user state changed to ${user != null}}');
    });
  }

  Future<void> _incrementCounter() async {
    print('/// Test login flow on ${_auth.app.name}');

    // sign out first for proper test
    await _auth.signOut();

    try {
      await _auth.signInWithEmailAndPassword(
        email: 'testuser@example.com',
        password: 'secret',
      );
    } on FirebaseAuthMultiFactorException catch (e) {
      print('/// MFA needed.');
      final firstHint = e.resolver.hints.first;
      if (firstHint is! PhoneMultiFactorInfo) {
        return;
      }
      await FirebaseAuth.instance.verifyPhoneNumber(
        multiFactorSession: e.resolver.session,
        multiFactorInfo: firstHint,
        verificationCompleted: (e) {
          print('verificationCompleted: ${e.toString()}.');
        },
        verificationFailed: (e) {
          print('verificationFailed error: ${e.toString()}.');
        },
        codeSent: (String verificationId, int? resendToken) async {
          const smsCode = '123456';

          final credential = PhoneAuthProvider.credential(
            verificationId: verificationId,
            smsCode: smsCode,
          );

          try {
            final result = await e.resolver.resolveSignIn(
              PhoneMultiFactorGenerator.getAssertion(
                credential,
              ),
            );
            if (result.user != null) {
              print(
                '/// Hi ${result.user?.email} 👋. CurrentUser: ${_auth.currentUser?.email}.',
              );
            }
          } on FirebaseAuthException catch (e) {
            print('resolveSignIn error: ${e.toString()}.');
          }
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      print('MFA error: ${e.toString()}.');
    }
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
