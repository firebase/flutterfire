// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('$User', () {
    String email = generateRandomEmail();

    group('getIdToken()', () {
      test('should return a token', () async {
        // Setup
        User? user;
        UserCredential userCredential;

        userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: testPassword,
        );
        user = userCredential.user;

        // Test
        String token = await user!.getIdToken();

        // // Assertions
        expect(token.length, greaterThan(24));
      });

      test('should catch error', () async {
        // Setup
        late User user;
        UserCredential userCredential;

        userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: testPassword,
        );
        user = userCredential.user!;

        // needed for method to throw an error
        await FirebaseAuth.instance.signOut();

        try {
          // Test
          await user.getIdToken();
        } on FirebaseAuthException catch (_) {
          return;
        } catch (e) {
          fail('should have thrown a FirebaseAuthException error');
        }
        fail('should have thrown an error');
      });
    });

    group('getIdTokenResult()', () {
      test('should return a valid IdTokenResult Object', () async {
        // Setup
        late User user;
        UserCredential userCredential;

        userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: testPassword,
        );
        user = userCredential.user!;

        // Test
        final idTokenResult = await user.getIdTokenResult();

        // Assertions
        expect(idTokenResult.token.runtimeType, equals(String));
        expect(idTokenResult.authTime.runtimeType, equals(DateTime));
        expect(idTokenResult.issuedAtTime.runtimeType, equals(DateTime));
        expect(idTokenResult.expirationTime.runtimeType, equals(DateTime));
        expect(idTokenResult.token!.length, greaterThan(24));
        expect(idTokenResult.signInProvider, equals('password'));
      });
      // TODO add custom claims and tenant id tests for id token result
    });

    group('linkWithCredential()', () {
      test('should link anonymous account <-> email account', () async {
        await FirebaseAuth.instance.signInAnonymously();
        String currentUID = FirebaseAuth.instance.currentUser!.uid;

        UserCredential linkedUserCredential =
            await FirebaseAuth.instance.currentUser!.linkWithCredential(
          EmailAuthProvider.credential(
            email: email,
            password: testPassword,
          ),
        );

        User linkedUser = linkedUserCredential.user!;
        expect(linkedUser.email, equals(email));
        expect(
          linkedUser.email,
          equals(FirebaseAuth.instance.currentUser!.email),
        );
        expect(linkedUser.uid, equals(currentUID));
        expect(linkedUser.isAnonymous, isFalse);
      });

      test('should error on link anon <-> email if email already exists',
          () async {
        // Setup

        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: testPassword,
        );
        await FirebaseAuth.instance.signInAnonymously();

        // Test
        try {
          await FirebaseAuth.instance.currentUser!.linkWithCredential(
            EmailAuthProvider.credential(
              email: email,
              password: testPassword,
            ),
          );
        } on FirebaseAuthException catch (e) {
          // Assertions
          expect(e.code, 'email-already-in-use');
          expect(
            e.message,
            'The email address is already in use by another account.',
          );

          // clean up
          await FirebaseAuth.instance.currentUser!.delete();
          return;
        }

        fail('should have thrown an error');
      });

      test(
        'should link anonymous account <-> phone account',
        () async {
          await FirebaseAuth.instance.signInAnonymously();

          Future<String> getVerificationId() {
            Completer completer = Completer<String>();

            unawaited(
              FirebaseAuth.instance.verifyPhoneNumber(
                phoneNumber: testPhoneNumber,
                verificationCompleted: (PhoneAuthCredential credential) {
                  fail('Should not have auto resolved');
                },
                verificationFailed: (FirebaseException e) {
                  fail('Should not have errored: $e');
                },
                codeSent: (String verificationId, int? resetToken) {
                  completer.complete(verificationId);
                },
                codeAutoRetrievalTimeout: (String foo) {},
              ),
            );

            return completer.future.then((value) => value as String);
          }

          String storedVerificationId = await getVerificationId();

          await FirebaseAuth.instance.currentUser!.linkWithCredential(
            PhoneAuthProvider.credential(
              verificationId: storedVerificationId,
              smsCode: (await emulatorPhoneVerificationCode(testPhoneNumber))!,
            ),
          );
          expect(FirebaseAuth.instance.currentUser, equals(isA<User>()));
          expect(
            FirebaseAuth.instance.currentUser!.phoneNumber,
            equals(testPhoneNumber),
          );
          expect(
            FirebaseAuth.instance.currentUser!.providerData,
            equals(isA<List<UserInfo>>()),
          );
          expect(
            FirebaseAuth.instance.currentUser!.providerData.length,
            equals(1),
          );
          expect(
            FirebaseAuth.instance.currentUser!.providerData[0],
            equals(isA<UserInfo>()),
          );
          expect(FirebaseAuth.instance.currentUser!.isAnonymous, isFalse);
          await FirebaseAuth.instance.currentUser
              ?.unlink(PhoneAuthProvider.PROVIDER_ID);
          await FirebaseAuth.instance.currentUser?.delete();
        },
        skip: kIsWeb || defaultTargetPlatform == TargetPlatform.macOS,
      ); // verifyPhoneNumber not supported on web.

      test(
        'should error on link anonymous account <-> phone account if invalid credentials',
        () async {
          // Setup
          await FirebaseAuth.instance.signInAnonymously();

          try {
            await FirebaseAuth.instance.currentUser!.linkWithCredential(
              PhoneAuthProvider.credential(
                verificationId: 'test',
                smsCode: 'test',
              ),
            );
          } on FirebaseAuthException catch (e) {
            expect(e.code, equals('invalid-verification-id'));
            expect(
              e.message,
              equals(
                'The verification ID used to create the phone auth credential is invalid.',
              ),
            );
            return;
          } catch (e) {
            fail('should have thrown an FirebaseAuthException');
          }

          fail('should have thrown an error');
        },
        skip: defaultTargetPlatform == TargetPlatform.macOS,
      );
    });

    group('reauthenticateWithCredential()', () {
      test('should reauthenticate correctly', () async {
        // Setup
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: testPassword,
        );
        User initialUser = FirebaseAuth.instance.currentUser!;

        // Test
        AuthCredential credential =
            EmailAuthProvider.credential(email: email, password: testPassword);
        await FirebaseAuth.instance.currentUser!
            .reauthenticateWithCredential(credential);

        // Assertions
        User currentUser = FirebaseAuth.instance.currentUser!;
        expect(currentUser.email, equals(email));
        expect(currentUser.uid, equals(initialUser.uid));
      });

      test('should throw user-mismatch ', () async {
        // Setup
        String emailAlready = generateRandomEmail();

        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: testPassword,
        );

        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailAlready,
          password: testPassword,
        );

        try {
          // Test
          AuthCredential credential = EmailAuthProvider.credential(
            email: email,
            password: testPassword,
          );
          await FirebaseAuth.instance.currentUser!
              .reauthenticateWithCredential(credential);
        } on FirebaseAuthException catch (e) {
          // Assertions
          expect(e.code, equals('user-mismatch'));
          expect(
            e.message,
            equals(
              'The supplied credentials do not correspond to the previously signed in user.',
            ),
          );
          await FirebaseAuth.instance.currentUser!.delete(); //clean up
          return;
        } catch (e) {
          fail('should have thrown an FirebaseAuthException');
        }

        fail('should have thrown an error');
      });

      test('should throw user-not-found or user-mismatch ', () async {
        // Setup
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: testPassword,
        );
        User user = userCredential.user!;

        try {
          // Test
          AuthCredential credential = EmailAuthProvider.credential(
            email: 'userdoesnotexist@foobar.com',
            password: testPassword,
          );
          await user.reauthenticateWithCredential(credential);
        } on FirebaseAuthException catch (e) {
          // Platforms throw different errors. For now, leave them as is
          // but in future we might want to edit them before sending to user.
          if (e.code != 'user-mismatch' && e.code != 'user-not-found') {
            fail('should have thrown a valid error code (got ${e.code}');
          }

          return;
        } catch (e) {
          fail('should have thrown an FirebaseAuthException');
        }

        fail('should have thrown an error');
      });

      // TODO error codes no longer match when using emulator.
      // test('should throw invalid-email ', () async {
      //   // Setup
      //   await FirebaseAuth.instance.createUserWithEmailAndPassword(
      //       email: email, password: testPassword);
      //
      //   try {
      //     // Test
      //     AuthCredential credential = EmailAuthProvider.credential(
      //         email: 'invalid', password: testPassword);
      //     await FirebaseAuth.instance.currentUser
      //         .reauthenticateWithCredential(credential);
      //   } on FirebaseAuthException catch (e) {
      //     // Assertions
      //     expect(e.code, equals('invalid-email'));
      //     expect(e.message, equals('The email address is badly formatted.'));
      //     return;
      //   } catch (e) {
      //     fail('should have thrown an FirebaseAuthException');
      //   }
      //
      //   fail('should have thrown an error');
      // });

      test('should throw wrong-password ', () async {
        // Setup
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: testPassword,
        );

        try {
          // Test
          AuthCredential credential = EmailAuthProvider.credential(
            email: email,
            password: 'WRONG_testPassword',
          );
          await FirebaseAuth.instance.currentUser!
              .reauthenticateWithCredential(credential);
        } on FirebaseAuthException catch (e) {
          // Assertions
          expect(e.code, equals('wrong-password'));
          expect(
            e.message,
            equals(
              'The password is invalid or the user does not have a password.',
            ),
          );
          return;
        } catch (e) {
          fail('should have thrown an FirebaseAuthException');
        }

        fail('should have thrown an error');
      });
    });

    group('reload()', () {
      test('should not error', () async {
        await FirebaseAuth.instance.signInAnonymously();
        try {
          await FirebaseAuth.instance.currentUser!.reload();
          await FirebaseAuth.instance.signOut();
        } catch (e) {
          fail('should not throw error');
        }
        expect(FirebaseAuth.instance.currentUser, isNull);
      });
    });

    group('sendEmailVerification()', () {
      test('should not error', () async {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: generateRandomEmail(),
          password: testPassword,
        );
        try {
          await FirebaseAuth.instance.currentUser!.sendEmailVerification();
        } catch (e) {
          fail('should not throw error');
        }
        expect(FirebaseAuth.instance.currentUser, isNotNull);
      });

      test(
        'should work with actionCodeSettings',
        () async {
          // Setup
          ActionCodeSettings actionCodeSettings = ActionCodeSettings(
            handleCodeInApp: true,
            url: 'https://flutterfire-e2e-tests.firebaseapp.com/foo',
          );
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: generateRandomEmail(),
            password: testPassword,
          );

          // Test
          try {
            await FirebaseAuth.instance.currentUser!
                .sendEmailVerification(actionCodeSettings);
          } catch (error) {
            fail('$error');
          }
          expect(FirebaseAuth.instance.currentUser, isNotNull);
        },
        skip: kIsWeb,
      );
    });

    group('unlink()', () {
      test('should unlink the email address', () async {
        // Setup
        await FirebaseAuth.instance.signInAnonymously();

        AuthCredential credential =
            EmailAuthProvider.credential(email: email, password: testPassword);
        await FirebaseAuth.instance.currentUser!.linkWithCredential(credential);

        // verify user is linked
        User linkedUser = FirebaseAuth.instance.currentUser!;
        expect(linkedUser.email, email);
        expect(linkedUser.providerData, isA<List<UserInfo>>());
        expect(linkedUser.providerData.length, equals(1));

        // Test
        await FirebaseAuth.instance.currentUser!
            .unlink(EmailAuthProvider.PROVIDER_ID);

        // Assertions
        User unlinkedUser = FirebaseAuth.instance.currentUser!;
        expect(unlinkedUser.providerData, isA<List<UserInfo>>());
        expect(unlinkedUser.providerData.length, equals(0));
      });

      test('should throw error if provider id given does not exist', () async {
        // Setup
        await FirebaseAuth.instance.signInAnonymously();

        AuthCredential credential =
            EmailAuthProvider.credential(email: email, password: testPassword);
        await FirebaseAuth.instance.currentUser!.linkWithCredential(credential);

        // verify user is linked
        User linkedUser = FirebaseAuth.instance.currentUser!;
        expect(linkedUser.email, email);

        // Test
        try {
          await FirebaseAuth.instance.currentUser!.unlink('invalid');
        } on FirebaseAuthException catch (e) {
          expect(e.code, 'no-such-provider');
          expect(
            e.message,
            'User was not linked to an account with the given provider.',
          );
          return;
        } catch (e) {
          fail('should have thrown an FirebaseAuthException error');
        }
        fail('should have thrown an error');
      });

      test('should throw error if user does not have this provider linked',
          () async {
        // Setup
        await FirebaseAuth.instance.signInAnonymously();
        // Test
        try {
          await FirebaseAuth.instance.currentUser!
              .unlink(EmailAuthProvider.PROVIDER_ID);
        } on FirebaseAuthException catch (e) {
          expect(e.code, 'no-such-provider');
          expect(
            e.message,
            'User was not linked to an account with the given provider.',
          );
          return;
        } catch (e) {
          fail('should have thrown an FirebaseAuthException error');
        }
        fail('should have thrown an error');
      });
    });

    group('updateEmail()', () {
      test('should update the email address', () async {
        String emailBefore = generateRandomEmail();
        // Setup
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailBefore,
          password: testPassword,
        );
        expect(FirebaseAuth.instance.currentUser!.email, equals(emailBefore));

        // Update user email
        await FirebaseAuth.instance.currentUser!.updateEmail(email);
        expect(FirebaseAuth.instance.currentUser!.email, equals(email));
      });
    });

    group('updatePassword()', () {
      test('should update the password', () async {
        String pass = '${testPassword}1';
        String pass2 = '${testPassword}2';
        // Setup
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: pass);

        // Update user password
        await FirebaseAuth.instance.currentUser!.updatePassword(pass2);

        // // Sign out
        await FirebaseAuth.instance.signOut();

        // Log in with the new password
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: pass2);

        // Assertions
        expect(FirebaseAuth.instance.currentUser, isA<Object>());
        expect(FirebaseAuth.instance.currentUser!.email, equals(email));
      });
      test('should throw error if password is weak', () async {
        // Setup
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: testPassword,
        );

        // Test
        try {
          // Update user password
          await FirebaseAuth.instance.currentUser!.updatePassword('weak');
        } on FirebaseAuthException catch (e) {
          expect(e.code, 'weak-password');
          expect(e.message, 'Password should be at least 6 characters');
          return;
        } catch (e) {
          fail('should have thrown an FirebaseAuthException error');
        }
        fail('should have thrown an error');
      });
    });

    group('refreshToken', () {
      test(
        'should throw an unsupported error on non web platforms',
        () async {
          // Setup
          await FirebaseAuth.instance.signInAnonymously();

          // Test
          FirebaseAuth.instance.currentUser!.refreshToken;

          // Assertions
          expect(
            FirebaseAuth.instance.currentUser!.refreshToken,
            isA<String>(),
          );
          expect(FirebaseAuth.instance.currentUser!.refreshToken, equals(''));
        },
        skip: kIsWeb,
      );

      test(
        'should return a token on web',
        () async {
          // Setup
          await FirebaseAuth.instance.signInAnonymously();

          // Test
          FirebaseAuth.instance.currentUser!.refreshToken;

          // Assertions
          expect(
            FirebaseAuth.instance.currentUser!.refreshToken,
            isA<String>(),
          );
          expect(
            FirebaseAuth.instance.currentUser!.refreshToken!.isEmpty,
            isFalse,
          );
        },
        skip: !kIsWeb,
      );
    });

    group('user.metadata', () {
      test(
          "should have the properties 'lastSignInTime' & 'creationTime' which are ISO strings",
          () async {
        // Setup
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: generateRandomEmail(),
          password: testPassword,
        );
        User user = FirebaseAuth.instance.currentUser!;

        // Test
        UserMetadata metadata = user.metadata;

        // Assertions
        expect(metadata.lastSignInTime, isA<DateTime>());
        expect(metadata.lastSignInTime!.year, DateTime.now().year);
        expect(metadata.creationTime, isA<DateTime>());
        expect(metadata.creationTime!.year, DateTime.now().year);
      });
    });

    group('updateDisplayName', () {
      test('updates the user displayName without impacting the photoURL',
          () async {
        // First create a user with a photo
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: testPassword,
        );
        await FirebaseAuth.instance.currentUser!.updateDisplayName('Mona Lisa');
        await FirebaseAuth.instance.currentUser!.updatePhotoURL(
          'http://photo.url/test.jpg',
        );
        await FirebaseAuth.instance.currentUser!.reload();

        expect(
          FirebaseAuth.instance.currentUser!.photoURL,
          'http://photo.url/test.jpg',
        );
        expect(
          FirebaseAuth.instance.currentUser!.displayName,
          'Mona Lisa',
        );

        await FirebaseAuth.instance.currentUser!
            .updateDisplayName('John Smith');
        await FirebaseAuth.instance.currentUser!.reload();

        expect(
          FirebaseAuth.instance.currentUser!.photoURL,
          'http://photo.url/test.jpg',
        );
        expect(
          FirebaseAuth.instance.currentUser!.displayName,
          'John Smith',
        );
      });

      test(
        'can set the displayName to null',
        () async {
          // First create a user with a photo
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: testPassword,
          );
          await FirebaseAuth.instance.currentUser!
              .updateDisplayName('Mona Lisa');
          await FirebaseAuth.instance.currentUser!.reload();

          // Just checking that the user indeed had a name before we set it to null
          expect(
            FirebaseAuth.instance.currentUser!.displayName,
            isNotNull,
          );

          await FirebaseAuth.instance.currentUser!.updateDisplayName(null);
          await FirebaseAuth.instance.currentUser!.reload();

          expect(
            FirebaseAuth.instance.currentUser!.displayName,
            isNull,
          );
          // Skip apple CI because of https://github.com/firebase/firebase-ios-sdk/issues/8149
          // Using `kIsWeb` because `Platform` is not available on web
        },
        // setting `displayName` on web throws an error
        skip: kIsWeb ||
            (defaultTargetPlatform == TargetPlatform.iOS ||
                defaultTargetPlatform == TargetPlatform.macOS),
      );
    });

    group('updatePhotoURL', () {
      test('updates the photoURL without impacting the displayName', () async {
        // First create a user with a photo
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: testPassword,
        );
        await Future.wait([
          FirebaseAuth.instance.currentUser!.updateDisplayName('Mona Lisa'),
          FirebaseAuth.instance.currentUser!.updatePhotoURL(
            'http://photo.url/test.jpg',
          ),
        ]);
        await FirebaseAuth.instance.currentUser!.reload();

        expect(
          FirebaseAuth.instance.currentUser!.photoURL,
          'http://photo.url/test.jpg',
        );
        expect(
          FirebaseAuth.instance.currentUser!.displayName,
          'Mona Lisa',
        );

        await FirebaseAuth.instance.currentUser!.updatePhotoURL(
          'http://photo.url/dash.jpg',
        );
        await FirebaseAuth.instance.currentUser!.reload();

        expect(
          FirebaseAuth.instance.currentUser!.photoURL,
          'http://photo.url/dash.jpg',
        );
        expect(
          FirebaseAuth.instance.currentUser!.displayName,
          'Mona Lisa',
        );
      });

      test(
        'can set the photoURL to null',
        () async {
          // First create a user with a photo
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: testPassword,
          );
          await FirebaseAuth.instance.currentUser!.updatePhotoURL(
            'http://photo.url/test.jpg',
          );
          await FirebaseAuth.instance.currentUser!.reload();

          // Just checking that the user indeed had a photo before we set it to null
          expect(
            FirebaseAuth.instance.currentUser!.photoURL,
            isNotNull,
          );

          await FirebaseAuth.instance.currentUser!.updatePhotoURL(null);
          await FirebaseAuth.instance.currentUser!.reload();

          expect(
            FirebaseAuth.instance.currentUser!.photoURL,
            isNull,
          );
        },
        // setting `photoURL` on web throws an error
        skip: kIsWeb,
      );
    });

    group('updateProfile()', () {
      test('should update the profile', () async {
        String displayName = 'testName';
        String photoURL = 'http://photo.url/test.jpg';

        // Setup
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: testPassword,
        );

        // Update user profile
        // ignore: deprecated_member_use
        await FirebaseAuth.instance.currentUser!.updateProfile(
          displayName: displayName,
          photoURL: photoURL,
        );

        await FirebaseAuth.instance.currentUser!.reload();
        User user = FirebaseAuth.instance.currentUser!;

        // Assertions
        expect(user, isA<Object>());
        expect(user.email, email);
        expect(user.displayName, equals(displayName));
        expect(user.photoURL, equals(photoURL));
      });
    });

    group('updatePhoneNumber()', () {
      // TODO this test is now flakey since switching to Auth emulator, consider
      //      rewriting it.
      // test('should update the phone number', () async {
      //   // Setup
      //   await FirebaseAuth.instance.signInAnonymously();
      //
      //   Future<String> getVerificationId() {
      //     Completer completer = Completer<String>();
      //
      //     unawaited(FirebaseAuth.instance.verifyPhoneNumber(
      //       phoneNumber: testPhoneNumber,
      //       verificationCompleted: (PhoneAuthCredential credential) {
      //         fail('Should not have auto resolved');
      //       },
      //       verificationFailed: (FirebaseException e) {
      //         fail('Should not have errored');
      //       },
      //       codeSent: (String verificationId, int resetToken) {
      //         completer.complete(verificationId);
      //       },
      //       codeAutoRetrievalTimeout: (String foo) {},
      //     ));
      //
      //     return completer.future;
      //   }
      //
      //   String storedVerificationId = await getVerificationId();
      //
      //   // Update user profile
      //   await FirebaseAuth.instance.currentUser
      //       .updatePhoneNumber(PhoneAuthProvider.credential(
      //     verificationId: storedVerificationId,
      //     smsCode: await emulatorPhoneVerificationCode(testPhoneNumber),
      //   ));
      //
      //   await FirebaseAuth.instance.currentUser.reload();
      //   User user = FirebaseAuth.instance.currentUser;
      //
      //   // Assertions
      //   expect(user, isA<Object>());
      //   expect(user.phoneNumber, equals(testPhoneNumber));
      // }, skip: kIsWeb || defaultTargetPlatform == TargetPlatform.macOS);

      test(
        'should throw an FirebaseAuthException if verification id is invalid',
        () async {
          // Setup
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: testPassword,
          );

          try {
            // Update user profile
            await FirebaseAuth.instance.currentUser!.updatePhoneNumber(
              PhoneAuthProvider.credential(
                verificationId: 'invalid',
                smsCode: '123456',
              ),
            );
          } on FirebaseAuthException catch (e) {
            expect(e.code, 'invalid-verification-id');
            expect(
              e.message,
              'The verification ID used to create the phone auth credential is invalid.',
            );
            return;
          } catch (e) {
            fail('should have thrown a AssertionError error');
          }

          fail('should have thrown an error');
        },
        skip: kIsWeb || defaultTargetPlatform == TargetPlatform.macOS,
      );

      // TODO error codes no longer match up on emulator
      // test('should throw an error when verification id is an empty string',
      //     () async {
      //   // Setup
      //   await FirebaseAuth.instance.createUserWithEmailAndPassword(
      //       email: email, password: testPassword);
      //
      //   try {
      //     // Test
      //     await FirebaseAuth.instance.currentUser.updatePhoneNumber(
      //         PhoneAuthProvider.credential(
      //             verificationId: '', smsCode: '123456'));
      //   } on FirebaseAuthException catch (e) {
      //     expect(e.code, 'invalid-verification-id');
      //     expect(e.message,
      //         'The verification ID used to create the phone auth credential is invalid.');
      //     return;
      //   } catch (e) {
      //     fail('should have thrown an FirebaseAuthException error');
      //   }
      //
      //   fail('should have thrown an error');
      // }, skip: kIsWeb || defaultTargetPlatform == TargetPlatform.macOS);
    });

    // TODO fails on emulator but works on live Firebase project
    // group('verifyBeforeUpdateEmail()', () {
    //   test(
    //     'should send verification email',
    //     () async {
    //       await ensureSignedIn(testEmail);
    //       await FirebaseAuth.instance.currentUser.verifyBeforeUpdateEmail(
    //           'updated-test-email@example.com',
    //           ActionCodeSettings(
    //             url: 'http://action-code-test.com',
    //             handleCodeInApp: true,
    //           ));
    //
    //       // Confirm with the Auth emulator that it triggered an email sending code.
    //       final oobCode = await emulatorOutOfBandCode(
    //           email, EmulatorOobCodeType.verifyEmail);
    //       expect(oobCode, isNotNull);
    //       expect(oobCode.email, testEmail);
    //       expect(oobCode.type, EmulatorOobCodeType.verifyEmail);
    //     },
    //   );
    // });

    group('delete()', () {
      test('should delete a user', () async {
        // Setup
        late User user;
        UserCredential userCredential;

        userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: testPassword,
        );
        user = userCredential.user!;

        // Test
        await user.delete();

        // Assertions
        expect(FirebaseAuth.instance.currentUser, equals(null));
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: email,
          password: testPassword,
        )
            .then((UserCredential userCredential) {
          expect(FirebaseAuth.instance.currentUser!.email, equals(email));
          return;
        }).catchError((Object error) {
          fail('Should have successfully created user after deletion');
        });
      });

      test('should throw an error on delete when no user is signed in',
          () async {
        // Setup
        late User user;
        UserCredential userCredential;

        userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: testPassword,
        );
        user = userCredential.user!;

        await FirebaseAuth.instance.signOut();

        try {
          // Test
          await user.delete();
        } on FirebaseAuthException catch (e) {
          // Assertions
          expect(e.code, 'no-current-user');
          expect(e.message, 'No user currently signed in.');

          return;
        } catch (e) {
          fail('Should have thrown an FirebaseAuthException error');
        }

        fail('Should have thrown an error');
      });
    });
  });
}
