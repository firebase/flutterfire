import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: kIsWeb
        ? const FirebaseOptions(
            apiKey: 'AIzaSyAgUhHU8wSJgO5MVNy95tMT07NEjzMOfz0',
            authDomain: 'react-native-firebase-testing.firebaseapp.com',
            databaseURL: 'https://react-native-firebase-testing.firebaseio.com',
            projectId: 'react-native-firebase-testing',
            storageBucket: 'react-native-firebase-testing.appspot.com',
            messagingSenderId: '448618578101',
            appId: '1:448618578101:web:2109c1424695f352ac3efc',
            trackingId: 'G-0N1G9FLDZE',
            iosClientId:
                '448618578101-gdvmskjsg1sk5v9pkifk73uqfr2ukta0.apps.googleusercontent.com',
            iosBundleId: 'io.flutter.plugins.firebase.appcheck.example',
          )
        : const FirebaseOptions(
            apiKey: 'AIzaSyAHAsf51D0A407EklG1bs-5wA7EbyfNFg0',
            authDomain: 'react-native-firebase-testing.firebaseapp.com',
            databaseURL: 'https://react-native-firebase-testing.firebaseio.com',
            projectId: 'react-native-firebase-testing',
            storageBucket: 'react-native-firebase-testing.appspot.com',
            messagingSenderId: '448618578101',
            appId: '1:448618578101:ios:eaf25c1747605f69ac3efc',
            trackingId: 'G-0N1G9FLDZE',
            iosClientId:
                '448618578101-gdvmskjsg1sk5v9pkifk73uqfr2ukta0.apps.googleusercontent.com',
            iosBundleId: 'io.flutter.plugins.firebase.appcheck.example',
          ),
  );

  // Activate app check after initialization, but before
  // usage of any Firebase services.
  await FirebaseAppCheck.instance
      // Your personal reCaptcha public key goes here:
      .activate(
    webRecaptchaSiteKey: '6Lemcn0dAAAAABLkf6aiiHvpGD6x-zF3nOSDU2M8',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String title = 'Firebase App Check';

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase App Check',
      home: FirebaseAppCheckExample(title: title),
    );
  }
}

class FirebaseAppCheckExample extends StatefulWidget {
  FirebaseAppCheckExample({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  _FirebaseAppCheck createState() => _FirebaseAppCheck();
}

class _FirebaseAppCheck extends State<FirebaseAppCheckExample> {
  final appCheck = FirebaseAppCheck.instance;
  String _message = '';
  String _eventToken = 'not yet';

  @override
  void initState() {
    appCheck.onTokenChange.listen(setEventToken);
    super.initState();
  }

  void setMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  void setEventToken(String? token) {
    setState(() {
      _eventToken = token ?? 'not yet';
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
          children: [
            ElevatedButton(
              onPressed: () async {
                if (kIsWeb) {
                  print(
                    'Pass in your "webRecaptchaSiteKey" key found on you Firebase Console to activate if using on the web platform.',
                  );
                }
                await appCheck.activate();
                setMessage('activated!!');
              },
              child: const Text('activate()'),
            ),
            ElevatedButton(
              onPressed: () async {
                final token = await appCheck.getToken(true);
                setMessage('your token: $token');
              },
              child: const Text('getToken()'),
            ),
            ElevatedButton(
              onPressed: () async {
                await appCheck.setTokenAutoRefreshEnabled(true);
                setMessage('successfully set auto token refresh!!');
              },
              child: const Text('setTokenAutoRefreshEnabled()'),
            ),
            const SizedBox(height: 20),
            Text(
              _message, //#007bff
              style: const TextStyle(
                color: Color.fromRGBO(47, 79, 79, 1),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Token received from tokenChanges() API: $_eventToken', //#007bff
              style: const TextStyle(
                color: Color.fromRGBO(128, 0, 128, 1),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
