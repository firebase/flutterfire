import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

typedef OAuthSignIn = void Function();

final FirebaseAuth _auth = FirebaseAuth.instance;

/// Helper class to show a snackbar using the passed context.
class ScaffoldSnackbar {
  // ignore: public_member_api_docs
  ScaffoldSnackbar(this._context);

  /// The scaffold of current context.
  factory ScaffoldSnackbar.of(BuildContext context) {
    return ScaffoldSnackbar(context);
  }

  final BuildContext _context;

  /// Helper method to show a SnackBar.
  void show(String message) {
    ScaffoldMessenger.of(_context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

/// The mode of the current auth session, either [AuthMode.login] or [AuthMode.register].
// ignore: public_member_api_docs
enum AuthMode { login, register, phone }

extension on AuthMode {
  String get label => this == AuthMode.login
      ? 'Sign in'
      : this == AuthMode.phone
          ? 'Sign in'
          : 'Register';
}

/// Entrypoint example for various sign-in flows with Firebase.
class AuthGate extends StatefulWidget {
  // ignore: public_member_api_docs
  const AuthGate({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String error = '';
  String verificationId = '';

  AuthMode mode = AuthMode.login;

  bool isLoading = false;

  void setIsLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  late Map<Buttons, OAuthSignIn> authButtons;

  @override
  void initState() {
    super.initState();

    authButtons = {
      Buttons.Google: _signInWithGoogle,
      if (Platform.isIOS || Platform.isMacOS) Buttons.Apple: _signInWithApple,
      Buttons.FacebookNew: _signInWithFacebook,
      Buttons.Twitter: _signInWithTwitter,
      Buttons.GitHub: _signInWithGitHub,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SafeArea(
                child: Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Visibility(
                        visible: error.isNotEmpty,
                        child: MaterialBanner(
                          backgroundColor: Theme.of(context).errorColor,
                          content: Text(error),
                          actions: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  error = '';
                                });
                              },
                              child: const Text(
                                'dismiss',
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          ],
                          contentTextStyle:
                              const TextStyle(color: Colors.white),
                          padding: const EdgeInsets.all(10),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (mode != AuthMode.phone)
                        Column(
                          children: [
                            TextFormField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                hintText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value != null && value.isNotEmpty
                                      ? null
                                      : 'Required',
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                hintText: 'Password',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value != null && value.isNotEmpty
                                      ? null
                                      : 'Required',
                            ),
                          ],
                        ),
                      if (mode == AuthMode.phone)
                        TextFormField(
                          controller: phoneController,
                          decoration: const InputDecoration(
                            hintText: '+12345678910',
                            labelText: 'Phone number',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value != null && value.isNotEmpty
                                  ? null
                                  : 'Required',
                        ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _emailAndPassword,
                          child: isLoading
                              ? const CircularProgressIndicator.adaptive()
                              : Text(mode.label),
                        ),
                      ),
                      TextButton(
                        onPressed: _resetPassword,
                        child: const Text('Forgot password?'),
                      ),
                      ...authButtons.keys
                          .map(
                            (button) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: isLoading
                                    ? Container(
                                        color: Colors.grey[200],
                                        height: 50,
                                        width: double.infinity,
                                      )
                                    : SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: SignInButton(
                                          button,
                                          onPressed: authButtons[button]!,
                                        ),
                                      ),
                              ),
                            ),
                          )
                          .toList(),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (mode != AuthMode.phone) {
                                    setState(() {
                                      mode = AuthMode.phone;
                                    });
                                  } else {
                                    setState(() {
                                      mode = AuthMode.login;
                                    });
                                  }
                                },
                          child: isLoading
                              ? const CircularProgressIndicator.adaptive()
                              : Text(
                                  mode != AuthMode.phone
                                      ? 'Sign in with Phone Number'
                                      : 'Sign in with Email and Password',
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (mode != AuthMode.phone)
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyText1,
                            children: [
                              TextSpan(
                                text: mode == AuthMode.login
                                    ? "Don't have an account? "
                                    : 'You have an account? ',
                              ),
                              TextSpan(
                                text: mode == AuthMode.login
                                    ? 'Register now'
                                    : 'Click to login',
                                style: const TextStyle(color: Colors.blue),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    setState(() {
                                      mode = mode == AuthMode.login
                                          ? AuthMode.register
                                          : AuthMode.login;
                                    });
                                  },
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 10),
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyText1,
                          children: [
                            const TextSpan(text: 'Or '),
                            TextSpan(
                              text: 'continue as guest',
                              style: const TextStyle(color: Colors.blue),
                              recognizer: TapGestureRecognizer()
                                ..onTap = _anonymousAuth,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _resetPassword() async {
    String? email;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Send'),
            ),
          ],
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your email'),
              const SizedBox(height: 20),
              TextFormField(
                onChanged: (value) {
                  email = value;
                },
              ),
            ],
          ),
        );
      },
    );

    if (email != null) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email!);
        ScaffoldSnackbar.of(context).show('Password reset email is sent');
      } catch (e) {
        ScaffoldSnackbar.of(context).show('Error resetting');
      }
    }
  }

  Future<void> _anonymousAuth() async {
    setIsLoading();

    try {
      await FirebaseAuth.instance.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = '${e.message}';
      });
    } catch (e) {
      setState(() {
        error = '$e';
      });
    } finally {
      setIsLoading();
    }
  }

  Future<void> _emailAndPassword() async {
    if (formKey.currentState?.validate() ?? false) {
      setIsLoading();

      try {
        if (mode == AuthMode.login) {
          await _auth.signInWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );
        } else if (mode == AuthMode.register) {
          await _auth.createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );
        } else {
          await _phoneAuth();
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          error = '${e.message}';
        });
      } catch (e) {
        setState(() {
          error = '$e';
        });
      } finally {
        setIsLoading();
      }
    }
  }

  Future<void> _phoneAuth() async {
    if (mode != AuthMode.phone) {
      setState(() {
        mode = AuthMode.phone;
      });
    } else {
      try {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneController.text,
          verificationCompleted: (_) {},
          verificationFailed: (e) {
            setState(() {
              error = '${e.message}';
            });
            setIsLoading();
          },
          codeSent: (String verificationId, int? resendToken) async {
            String? smsCode;

            // Update the UI - wait for the user to enter the SMS code
            await showDialog<String>(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: const Text('SMS code:'),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Sign in'),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        smsCode = null;
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                  content: Container(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      onChanged: (value) {
                        smsCode = value;
                      },
                      textAlign: TextAlign.center,
                      autofocus: true,
                    ),
                  ),
                );
              },
            );

            if (smsCode == null) {
              setIsLoading();
              return;
            }

            // Create a PhoneAuthCredential with the code
            final credential = PhoneAuthProvider.credential(
              verificationId: verificationId,
              smsCode: smsCode!,
            );

            try {
              // Sign the user in (or link) with the credential
              await FirebaseAuth.instance.signInWithCredential(credential);
            } on FirebaseAuthException catch (e) {
              setState(() {
                error = e.message ?? '';
              });
            }
            setIsLoading();
          },
          codeAutoRetrievalTimeout: (e) {
            setState(() {
              error = e;
            });
            setIsLoading();
          },
        );
      } catch (e) {
        setIsLoading();

        setState(() {
          error = '$e';
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setIsLoading();
    try {
      // Trigger the authentication flow
      final googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final googleAuth = await googleUser?.authentication;

      if (googleAuth != null) {
        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Once signed in, return the UserCredential
        await _auth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = '${e.message}';
      });
    } finally {
      setIsLoading();
    }
  }

  Future<void> _signInWithFacebook() async {
    setIsLoading();

    try {} on FirebaseAuthException catch (e) {
      setState(() {
        error = '${e.message}';
      });
    } finally {
      setIsLoading();
    }
  }

  Future<void> _signInWithTwitter() async {
    setIsLoading();

    try {} on FirebaseAuthException catch (e) {
      setState(() {
        error = '${e.message}';
      });
    } finally {
      setIsLoading();
    }
  }

  Future<void> _signInWithGitHub() async {
    setIsLoading();

    try {} on FirebaseAuthException catch (e) {
      setState(() {
        error = '${e.message}';
      });
    } finally {
      setIsLoading();
    }
  }

  /// Apple sign in was added to iOS and macOS, but it's possible to setup
  /// on Android and Web by following the instructions in the plugins README.
  Future<void> _signInWithApple() async {
    setIsLoading();

    try {
      // To prevent replay attacks with the credential returned from Apple, we
      // include a nonce in the credential request. When signing in with
      // Firebase, the nonce in the id token returned by Apple, is expected to
      // match the sha256 hash of `rawNonce`.
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = '${e.message}';
      });
    } finally {
      setIsLoading();
    }
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
