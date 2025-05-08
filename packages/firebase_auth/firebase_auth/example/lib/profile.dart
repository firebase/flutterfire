// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_example/main.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'auth.dart';
import 'dart:io';

/// Displayed as a profile image if the user doesn't have one.
const placeholderImage =
    'https://upload.wikimedia.org/wikipedia/commons/c/cd/Portrait_Placeholder_Square.png';

/// Profile page shows after sign in or registration.
class ProfilePage extends StatefulWidget {
  // ignore: public_member_api_docs
  const ProfilePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User user;
  late TextEditingController controller;
  final phoneController = TextEditingController();

  String? photoURL;

  bool showSaveButton = false;
  bool isLoading = false;

  @override
  void initState() {
    user = auth.currentUser!;
    final FirebaseStorage _storage = FirebaseStorage.instance;
    controller = TextEditingController(text: user.displayName);

    controller.addListener(_onNameChanged);

    auth.userChanges().listen((event) {
      if (event != null && mounted) {
        setState(() {
          user = event;
        });
      }
    });

    log(user.toString());

    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(_onNameChanged);

    super.dispose();
  }

  void setIsLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  void _onNameChanged() {
    setState(() {
      if (controller.text == user.displayName || controller.text.isEmpty) {
        showSaveButton = false;
      } else {
        showSaveButton = true;
      }
    });
  }

  /// Map User provider data into a list of Provider Ids.
  List get userProviders => user.providerData.map((e) => e.providerId).toList();

  Future updateDisplayName() async {
    await user.updateDisplayName(controller.text);

    setState(() {
      showSaveButton = false;
    });

    // ignore: use_build_context_synchronously
    ScaffoldSnackbar.of(context).show('Name updated');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        body: Stack(
          children: [
            Center(
              child: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            maxRadius: 60,
                            backgroundImage: NetworkImage(
                              user.photoURL ?? placeholderImage,
                            ),
                          ),
                          Positioned.directional(
                            textDirection: Directionality.of(context),
                            end: 0,
                            bottom: 0,
                            child: Material(
                              clipBehavior: Clip.antiAlias,
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(40),
                              child: InkWell(
                                onTap: () async {
  await ProfileUpdateService().pickAndUploadImage();
},
                                radius: 50,
                                child: const SizedBox(
                                  width: 35,
                                  height: 35,
                                  child: Icon(Icons.edit),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        textAlign: TextAlign.center,
                        controller: controller,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          alignLabelWithHint: true,
                          label: Center(
                            child: Text(
                              'Click to add a display name',
                            ),
                          ),
                        ),
                      ),
                      Text(user.email ?? user.phoneNumber ?? 'User'),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (userProviders.contains('phone'))
                            const Icon(Icons.phone),
                          if (userProviders.contains('password'))
                            const Icon(Icons.mail),
                          if (userProviders.contains('google.com'))
                            SizedBox(
                              width: 24,
                              child: Image.network(
                                'https://upload.wikimedia.org/wikipedia/commons/0/09/IOS_Google_icon.png',
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          user.sendEmailVerification();
                        },
                        child: const Text('Verify Email'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final a = await user.multiFactor.getEnrolledFactors();
                          print(a);
                        },
                        child: const Text('Get enrolled factors'),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (AuthGate.appleAuthorizationCode != null) {
                            // The `authorizationCode` is on the user credential.
                            // e.g. final authorizationCode = userCredential.additionalUserInfo?.authorizationCode;
                            await FirebaseAuth.instance
                                .revokeTokenWithAuthorizationCode(
                              AuthGate.appleAuthorizationCode!,
                            );
                            // You may wish to delete the user at this point
                            AuthGate.appleAuthorizationCode = null;
                          } else {
                            print(
                              'Apple `authorizationCode` is null, cannot revoke token.',
                            );
                          }
                        },
                        child: const Text('Revoke Apple auth token'),
                      ),
                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.phone),
                          hintText: '+33612345678',
                          labelText: 'Phone number',
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () async {
                          final session = await user.multiFactor.getSession();
                          await auth.verifyPhoneNumber(
                            multiFactorSession: session,
                            phoneNumber: phoneController.text,
                            verificationCompleted: (_) {},
                            verificationFailed: print,
                            codeSent: (
                              String verificationId,
                              int? resendToken,
                            ) async {
                              final smsCode = await getSmsCodeFromUser(context);

                              if (smsCode != null) {
                                // Create a PhoneAuthCredential with the code
                                final credential = PhoneAuthProvider.credential(
                                  verificationId: verificationId,
                                  smsCode: smsCode,
                                );

                                try {
                                  await user.multiFactor.enroll(
                                    PhoneMultiFactorGenerator.getAssertion(
                                      credential,
                                    ),
                                  );
                                } on FirebaseAuthException catch (e) {
                                  print(e.message);
                                }
                              }
                            },
                            codeAutoRetrievalTimeout: print,
                          );
                        },
                        child: const Text('Verify Number For MFA'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final totp =
                              (await user.multiFactor.getEnrolledFactors())
                                  .firstWhereOrNull(
                            (element) => element.factorId == 'totp',
                          );
                          if (totp != null) {
                            await user.multiFactor.unenroll(
                              factorUid:
                                  (await user.multiFactor.getEnrolledFactors())
                                      .firstWhere(
                                        (element) => element.factorId == 'totp',
                                      )
                                      .uid,
                            );
                          }
                          final session = await user.multiFactor.getSession();
                          final totpSecret =
                              await TotpMultiFactorGenerator.generateSecret(
                            session,
                          );
                          print(totpSecret);
                          final code =
                              await getTotpFromUser(context, totpSecret);
                          print('code: $code');
                          if (code == null) {
                            return;
                          }
                          await user.multiFactor.enroll(
                            await TotpMultiFactorGenerator
                                .getAssertionForEnrollment(
                              totpSecret,
                              code,
                            ),
                            displayName: 'TOTP',
                          );
                        },
                        child: const Text('Enroll TOTP'),
                      ),
                      TextButton(
                        onPressed: () async {
                          try {
                            final enrolledFactors =
                                await user.multiFactor.getEnrolledFactors();

                            await user.multiFactor.unenroll(
                              factorUid: enrolledFactors.first.uid,
                            );
                            // Show snackbar
                            ScaffoldSnackbar.of(context).show('MFA unenrolled');
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: const Text('Unenroll MFA'),
                      ),
                      const Divider(),
                      TextButton(
                        onPressed: _signOut,
                        child: const Text('Sign out'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.directional(
              textDirection: Directionality.of(context),
              end: 40,
              top: 40,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: !showSaveButton
                    ? SizedBox(key: UniqueKey())
                    : TextButton(
                        onPressed: isLoading ? null : updateDisplayName,
                        child: const Text('Save changes'),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> getPhotoURLFromUser() async {
    String? photoURL;

    // Update the UI - wait for the user to enter the SMS code
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('New image Url:'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
            OutlinedButton(
              onPressed: () {
                photoURL = null;
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
          content: Container(
            padding: const EdgeInsets.all(20),
            child: TextField(
              onChanged: (value) {
                photoURL = value;
              },
              textAlign: TextAlign.center,
              autofocus: true,
            ),
          ),
        );
      },
    );

    return photoURL;
  }

  /// Example code for sign out.
  Future<void> _signOut() async {
    await auth.signOut();
    await GoogleSignIn().signOut();
  }
}

class ProfileUpdateService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance; // Using default instance

  // --- Method using putFile ---
  Future<void> updateProfilePicture(File imageFile) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    if (!await imageFile.exists()) throw Exception('Image file does not exist');

    final String uid = user.uid;
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String fileExtension = imageFile.path.split('.').last;
    final String fileName = 'profile_$timestamp.$fileExtension';
    final String filePath = 'auth-storage-test/$uid/$fileName';

    if (kDebugMode) {
      print('Attempting profile picture upload using putFile:');
      print('  User ID: $uid');
      print('  File Path: $filePath');
      print('  Source File Path: ${imageFile.path}');
      print('  File Exists: ${await imageFile.exists()}');
      print('  File Length: ${await imageFile.length()} bytes');
    }

    try {
      // Attempt to refresh token explicitly (kept from previous troubleshooting, can be removed if desired for absolute minimum)
      if (kDebugMode) print('Attempting to refresh ID token...');
      await user.getIdToken(true); // Force refresh
      if (kDebugMode) print('ID token refreshed successfully.');

      print('Uploading profile picture (putFile) to: $filePath');

      // Using default instance, or FirebaseStorage.instanceFor(app: Firebase.app()) if preferred
      final Reference storageRef = _storage.ref(filePath);

      // Upload file using putFile
      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Update user's photoURL in Firebase Auth
      await user.updatePhotoURL(downloadUrl);
      await user.reload(); // Reload user data

      print('Upload successful!');

    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('FirebaseException during profile picture upload (putFile): Code: ${e.code}, Message: ${e.message}, Plugin: ${e.plugin}, StackTrace: ${e.stackTrace}');
      }
      // *** THIS IS THE ERROR OBSERVED AFTER LOGOUT/LOGIN ***
      // Error: FirebaseException: Code: unknown, Message: cannot parse response, Plugin: firebase_storage (iOS 18.4)
      // Error: FirebaseException: Code: unknown, Message: The operation couldn’t be completed. Message too long, Plugin: firebase_storage (iOS 18.3)
      rethrow;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Unexpected error updating profile picture (putFile): $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  // --- UI Interaction Snippet (Illustrative) ---
  Future<void> pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imageXFile = await picker.pickImage(source: ImageSource.gallery);

    if (imageXFile != null) {
      File imageFile = File(imageXFile.path); // Convert XFile to File
      try {
        // Assume ProfileUpdateService instance is available (e.g., via Provider)
        await ProfileUpdateService().updateProfilePicture(imageFile);
        // Show success message
      } catch (e) {
        // Show error message (this catches the FirebaseException after rethrow)
        print('Upload failed: $e');
      }
    }
  }
}
