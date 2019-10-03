// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();
final ValueNotifier<String> _messageNotifier = ValueNotifier<String>("");

final EdgeInsets _cardPadding = const EdgeInsets.all(8);

class SignInPage extends StatefulWidget {
  final String title = 'Registration';

  @override
  State<StatefulWidget> createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  @override
  void initState() {
    super.initState();
    _messageNotifier.addListener(_handleMessage);
  }

  void _handleMessage() {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(8),
            child: Text(
              _messageNotifier.value,
            ),
            height: 100,
          );
        });
  }

  @override
  void dispose() {
    _messageNotifier.removeListener(_handleMessage);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Builder(builder: (BuildContext context) {
            return FlatButton(
              child: const Text('Sign out'),
              textColor: Theme.of(context).buttonColor,
              onPressed: () async {
                final FirebaseUser user = await _auth.currentUser();
                if (user == null) {
                  _messageNotifier.value = 'No one has signed in.';
                  return;
                }
                // Example code for sign out.
                await _auth.signOut();
                _messageNotifier.value =
                '${user.uid} has successfully signed out.';
              },
            );
          })
        ],
      ),
      body: Builder(builder: (BuildContext context) {
        return ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            _EmailPasswordForm(),
            _EmailLinkSignInSection(),
            _AnonymouslySignInSection(),
            _GoogleSignInSection(),
            _PhoneSignInSection(),
            _OtherProvidersSignInSection(),
          ],
        );
      }),
    );
  }
}

class _EmailPasswordForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EmailPasswordFormState();
}

class _EmailPasswordFormState extends State<_EmailPasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: _cardPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: const Text('Test sign in with email and password'),
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                alignment: Alignment.center,
                child: RaisedButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      try {
                        // Example code of how to sign in with email and password.
                        final AuthResult authRes = await _auth.signInWithEmailAndPassword(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                        _messageNotifier.value =
                        'Successfully signed in ${authRes.user.email}';
                      } on Exception catch (e) {
                        _messageNotifier.value = 'Sign in failed: $e';
                      }
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class _EmailLinkSignInSection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EmailLinkSignInSectionState();
}

class _EmailLinkSignInSectionState extends State<_EmailLinkSignInSection>
    with WidgetsBindingObserver {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _trySignInWithDynamicLink() async {
    final PendingDynamicLinkData data =
    await FirebaseDynamicLinks.instance.retrieveDynamicLink();

    final Uri link = data?.link;
    if (link != null) {
      final AuthResult authRes = await _auth.signInWithEmailAndLink(
        email: _emailController.text,
        link: link.toString(),
      );
      if (authRes.user != null) {
        _messageNotifier.value = 'Successfully signed in, uid: ${authRes.user.uid}';
      } else {
        _messageNotifier.value = 'Sign in failed';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: _cardPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: const Text('Test sign in with email and link'),
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'Please enter your email.';
                  }
                  return null;
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                alignment: Alignment.center,
                child: Column(
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _signInWithEmailAndLink();
                        }
                      },
                      child: const Text('Send sign in with email link'),
                    ),
                    RaisedButton(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _trySignInWithDynamicLink();
                        }
                      },
                      child: const Text(
                          'Try to retreive dynamic link and sign in'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithEmailAndLink() async {
    return await _auth.sendSignInWithEmailLink(
      email: _emailController.text,
      url: '<Url with domain from your Firebase project>',
      handleCodeInApp: true,
      iOSBundleID: 'io.flutter.plugins.firebaseAuthExample',
      androidPackageName: 'io.flutter.plugins.firebaseauthexample',
      androidInstallIfNotAvailable: true,
      androidMinimumVersion: "1",
    );
  }
}

class _AnonymouslySignInSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: _cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: const Text('Test sign in anonymously'),
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              alignment: Alignment.center,
              child: RaisedButton(
                onPressed: () {
                  _signInAnonymously();
                },
                child: const Text('Sign in anonymously'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Example code of how to sign in anonymously.
  void _signInAnonymously() async {
    try {
      final AuthResult authRes = await _auth.signInAnonymously();
      assert(authRes.user != null);
      assert(authRes.user.isAnonymous);
      assert(!authRes.user.isEmailVerified);
      assert(await authRes.user.getIdToken() != null);
      if (Platform.isIOS) {
        // Anonymous auth doesn't show up as a provider on iOS
        assert(authRes.user.providerData.isEmpty);
      } else if (Platform.isAndroid) {
        // Anonymous auth does show up as a provider on Android
        assert(authRes.user.providerData.length == 1);
        assert(authRes.user.providerData[0].providerId == 'firebase');
        assert(authRes.user.providerData[0].uid != null);
        assert(authRes.user.providerData[0].displayName == null);
        assert(authRes.user.providerData[0].photoUrl == null);
        assert(authRes.user.providerData[0].email == null);
      }

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(authRes.user.uid == currentUser.uid);
      _messageNotifier.value = 'Successfully signed in, uid: ${authRes.user.uid}';
    } on Exception catch (e) {
      _messageNotifier.value = 'Sign in failed: $e';
    }
  }
}

class _GoogleSignInSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: _cardPadding,
        child: Column(
          children: <Widget>[
            Container(
              child: const Text('Test sign in with Google'),
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              alignment: Alignment.center,
              child: RaisedButton(
                onPressed: () async {
                  _signInWithGoogle();
                },
                child: const Text('Sign in with Google'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
      await googleUser?.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      final AuthResult authRes = await _auth.signInWithCredential(credential);
      assert(authRes.user != null && authRes.user.email != null);
      assert(authRes.user.displayName != null);
      assert(!authRes.user.isAnonymous);
      assert(await authRes.user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(authRes.user.uid == currentUser.uid);
      _messageNotifier.value = 'Successfully signed in, uid: ${authRes.user.uid}';
    } on Exception catch (e) {
      _messageNotifier.value = 'Sign in failed: $e';
    }
  }
}

class _PhoneSignInSection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PhoneSignInSectionState();
}

class _PhoneSignInSectionState extends State<_PhoneSignInSection> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();

  String _verificationId;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: _cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: const Text('Test sign in with phone number'),
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
            ),
            TextFormField(
              controller: _phoneNumberController,
              decoration:
              const InputDecoration(labelText: 'Phone number (+x xxx-xxx-xxxx)'),
              validator: (String value) {
                if (value.isEmpty) {
                  return 'Phone number (+x xxx-xxx-xxxx)';
                }
                return null;
              },
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              alignment: Alignment.center,
              child: RaisedButton(
                onPressed: () async {
                  _verifyPhoneNumber();
                },
                child: const Text('Verify phone number'),
              ),
            ),
            TextField(
              controller: _smsController,
              decoration: const InputDecoration(labelText: 'Verification code'),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              alignment: Alignment.center,
              child: RaisedButton(
                onPressed: () async {
                  _signInWithPhoneNumber();
                },
                child: const Text('Sign in with phone number'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Example code of how to verify phone number
  void _verifyPhoneNumber() async {
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      _auth.signInWithCredential(phoneAuthCredential);
      _messageNotifier.value =
      'Received phone auth credential: $phoneAuthCredential';
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      _messageNotifier.value =
      'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}';
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      _messageNotifier.value =
      'Please check your phone for the verification code.';
      _verificationId = verificationId;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
    };

    await _auth.verifyPhoneNumber(
        phoneNumber: _phoneNumberController.text,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  // Example code of how to sign in with phone.
  void _signInWithPhoneNumber() async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: _verificationId,
      smsCode: _smsController.text,
    );
    final AuthResult authRes = await _auth.signInWithCredential(credential);
    final FirebaseUser currentUser = await _auth.currentUser();
    assert(authRes.user.uid == currentUser.uid);
    if (authRes.user != null) {
      _messageNotifier.value = 'Successfully signed in, uid: ' + authRes.user.uid;
    } else {
      _messageNotifier.value = 'Sign in failed';
    }
  }
}

class _OtherProvidersSignInSection extends StatefulWidget {
  _OtherProvidersSignInSection();

  @override
  State<StatefulWidget> createState() => _OtherProvidersSignInSectionState();
}

class _OtherProvidersSignInSectionState
    extends State<_OtherProvidersSignInSection> {
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _tokenSecretController = TextEditingController();

  int _selection = 0;
  bool _showAuthSecretTextField = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: _cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: const Text(
                  'Test other providers authentication. (We do not provide an API to obtain the token for below providers. Please use a third party service to obtain token for below providers.)'),
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Radio<int>(
                    value: 0,
                    groupValue: _selection,
                    onChanged: _handleRadioButtonSelected,
                  ),
                  const Text(
                    'Github',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Radio<int>(
                    value: 1,
                    groupValue: _selection,
                    onChanged: _handleRadioButtonSelected,
                  ),
                  const Text(
                    'Facebook',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  Radio<int>(
                    value: 2,
                    groupValue: _selection,
                    onChanged: _handleRadioButtonSelected,
                  ),
                  const Text(
                    'Twitter',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ),
            TextField(
              controller: _tokenController,
              decoration: const InputDecoration(labelText: 'Enter provider\'s token'),
            ),
            Container(
              child: _showAuthSecretTextField
                  ? TextField(
                controller: _tokenSecretController,
                decoration: const InputDecoration(
                    labelText: 'Enter provider\'s authTokenSecret'),
              )
                  : null,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              alignment: Alignment.center,
              child: RaisedButton(
                onPressed: () async {
                  _signInWithOtherProvider();
                },
                child: const Text('Sign in'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleRadioButtonSelected(int value) {
    setState(() {
      _selection = value;
      if (_selection == 2) {
        _showAuthSecretTextField = true;
      } else {
        _showAuthSecretTextField = false;
      }
    });
  }

  void _signInWithOtherProvider() {
    switch (_selection) {
      case 0:
        _signInWithGithub();
        break;
      case 1:
        _signInWithFacebook();
        break;
      case 2:
        _signInWithTwitter();
        break;
      default:
    }
  }

  // Example code of how to sign in with Github.
  void _signInWithGithub() async {
    final AuthCredential credential = GithubAuthProvider.getCredential(
      token: _tokenController.text,
    );
    final AuthResult authRes = await _auth.signInWithCredential(credential);
    assert(authRes.user.email != null);
    assert(authRes.user.displayName != null);
    assert(!authRes.user.isAnonymous);
    assert(await authRes.user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(authRes.user.uid == currentUser.uid);
    if (authRes.user != null) {
      _messageNotifier.value =
          'Successfully signed in with Github. ' + authRes.user.uid;
    } else {
      _messageNotifier.value = 'Failed to sign in with Github. ';
    }
  }

  // Example code of how to sign in with Facebook.
  void _signInWithFacebook() async {
    final AuthCredential credential = FacebookAuthProvider.getCredential(
      accessToken: _tokenController.text,
    );
    final AuthResult authResult = await _auth.signInWithCredential(credential);
    assert(authResult.user.email != null);
    assert(authResult.user.displayName != null);
    assert(!authResult.user.isAnonymous);
    assert(await authResult.user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(authResult.user.uid == currentUser.uid);
    if (authResult.user != null) {
      _messageNotifier.value =
          'Successfully signed in with Facebook. ' + authResult.user.uid;
    } else {
      _messageNotifier.value = 'Failed to sign in with Facebook. ';
    }
  }

  // Example code of how to sign in with Twitter.
  void _signInWithTwitter() async {
    final AuthCredential credential = TwitterAuthProvider.getCredential(
        authToken: _tokenController.text,
        authTokenSecret: _tokenSecretController.text);
    final AuthResult authResult = await _auth.signInWithCredential(credential);
    assert(authResult.user.email != null);
    assert(authResult.user.displayName != null);
    assert(!authResult.user.isAnonymous);
    assert(await authResult.user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(authResult.user.uid == currentUser.uid);
    if (authResult.user != null) {
      _messageNotifier.value =
          'Successfully signed in with Twitter. ' + authResult.user.uid;
    } else {
      _messageNotifier.value = 'Failed to sign in with Twitter. ';
    }
  }
}
