
// SuperChat - Flutter + Firebase // Features: Login/Signup, Realtime Chat, Emoji, Call (Voice)

// pubspec.yaml dependencies name: superchat description: SuperChat App version: 1.0.0+1

environment: sdk: '>=3.0.0 <4.0.0'

dependencies: flutter: sdk: flutter firebase_core: ^2.10.0 firebase_auth: ^6.5.0 cloud_firestore: ^5.6.0 flutter_emoji_picker: ^1.0.2 agora_rtc_engine: ^7.2.0 cupertino_icons: ^1.0.5

// main.dart import 'package:flutter/material.dart'; import 'package:firebase_core/firebase_core.dart'; import 'login_screen.dart';

void main() async { WidgetsFlutterBinding.ensureInitialized(); await Firebase.initializeApp(); runApp(MyApp()); }

class MyApp extends StatelessWidget { @override Widget build(BuildContext context) { return MaterialApp( title: 'SuperChat', theme: ThemeData( primarySwatch: Colors.blue, ), home: LoginScreen(), ); } }

// login_screen.dart import 'package:flutter/material.dart'; import 'package:firebase_auth/firebase_auth.dart'; import 'user_list_screen.dart';

class LoginScreen extends StatefulWidget { @override _LoginScreenState createState() => _LoginScreenState(); }

class _LoginScreenState extends State<LoginScreen> { final TextEditingController emailController = TextEditingController(); final TextEditingController passwordController = TextEditingController(); final FirebaseAuth _auth = FirebaseAuth.instance;

void login() async { try { await auth.signInWithEmailAndPassword( email: emailController.text, password: passwordController.text, ); Navigator.pushReplacement( context, MaterialPageRoute(builder: () => UserListScreen()), ); } catch (e) { print('Login Error: $e'); } }

void signup() async { try { await auth.createUserWithEmailAndPassword( email: emailController.text, password: passwordController.text, ); Navigator.pushReplacement( context, MaterialPageRoute(builder: () => UserListScreen()), ); } catch (e) { print('Signup Error: $e'); } }

@override Widget build(BuildContext context) { return Scaffold( appBar: AppBar(title: Text('SuperChat Login')), body: Padding( padding: EdgeInsets.all(16), child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [ TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')), TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true), SizedBox(height: 20), Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [ ElevatedButton(onPressed: login, child: Text('Login')), ElevatedButton(onPressed: signup, child: Text('Signup')), ], ), ], ), ), ); } }
## Contribu
