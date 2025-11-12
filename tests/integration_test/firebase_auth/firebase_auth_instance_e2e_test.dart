// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tests/firebase_options.dart';

import './test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group(
    'FirebaseAuth.instance',
    () {
      Future<void> commonSuccessCallback(currentUserCredential) async {
        var currentUser = currentUserCredential.user;

        expect(currentUser, isInstanceOf<Object>());
        expect(currentUser.uid, isInstanceOf<String>());
        expect(currentUser.email, equals(testEmail));
        expect(currentUser.isAnonymous, isFalse);
        expect(currentUser.uid, equals(FirebaseAuth.instance.currentUser!.uid));

        var additionalUserInfo = currentUserCredential.additionalUserInfo;
        expect(additionalUserInfo, isInstanceOf<Object>());
        expect(additionalUserInfo.isNewUser, isFalse);

        await FirebaseAuth.instance.signOut();
      }

      group('authStateChanges()', () {
        StreamSubscription? subscription;

        tearDown(() async {
          await subscription?.cancel();
          await ensureSignedOut();
        });

        test('calls callback with the current user and when auth state changes',
            () async {
          await ensureSignedIn(testEmail);
          String uid = FirebaseAuth.instance.currentUser!.uid;

          Stream<User?> stream = FirebaseAuth.instance.authStateChanges();
          int call = 0;

          subscription = stream.listen(
            expectAsync1(
              (User? user) {
                call++;
                if (call == 1) {
                  expect(user!.uid, isA<String>());
                  expect(user.uid, equals(uid)); // initial user
                } else if (call == 2) {
                  expect(user, isNull); // logged out
                } else if (call == 3) {
                  expect(user!.uid, isA<String>());
                  expect(user.uid != uid, isTrue); // anonymous user
                } else {
                  fail('Should not have been called');
                }
              },
              count: 3,
              reason: 'Stream should only have been called 3 times',
            ),
          );

          // Prevent race condition where signOut is called before the stream hits
          await FirebaseAuth.instance.signOut();
          await FirebaseAuth.instance.signInAnonymously();
        });
      });

      group('idTokenChanges()', () {
        StreamSubscription? subscription;

        tearDown(() async {
          await subscription?.cancel();
          await ensureSignedOut();
        });

        test('calls callback with the current user and when auth state changes',
            () async {
          await ensureSignedIn(testEmail);
          String uid = FirebaseAuth.instance.currentUser!.uid;

          Stream<User?> stream = FirebaseAuth.instance.idTokenChanges();
          int call = 0;

          subscription = stream.listen(
            expectAsync1(
              (User? user) {
                call++;
                if (call == 1) {
                  expect(user!.uid, equals(uid)); // initial user
                } else if (call == 2) {
                  expect(user, isNull); // logged out
                } else if (call == 3) {
                  expect(user!.uid, isA<String>());
                  expect(user.uid != uid, isTrue); // anonymous user
                } else {
                  fail('Should not have been called');
                }
              },
              count: 3,
              reason: 'Stream should only have been called 3 times',
            ),
          );

          // Prevent race condition where signOut is called before the stream hits
          await FirebaseAuth.instance.signOut();
          await FirebaseAuth.instance.signInAnonymously();
        });
      });

      group(
        'userChanges()',
        () {
          late StreamSubscription subscription;
          tearDown(() async {
            await subscription.cancel();
          });

          test('fires once on first initialization of FirebaseAuth', () async {
            // Fixes a very specific bug: https://github.com/firebase/flutterfire/issues/3628
            // If the first initialization of FirebaseAuth involves the listeners userChanges() or idTokenChanges()
            // the user will receive two events. Why? The native SDK listener will always fire an event upon initial
            // listen. FirebaseAuth also sends an initial synthetic event. We send a synthetic event because, ordinarily, the user will
            // not use a listener as the first occurrence of FirebaseAuth. We, therefore, mimic native behavior by sending an
            // event. This test proves the logic of PR: https://github.com/firebase/flutterfire/pull/6560

            // Requires a fresh app.
            FirebaseApp second = await Firebase.initializeApp(
              name: 'test-init',
              options: DefaultFirebaseOptions.currentPlatform,
            );

            Stream<User?> stream =
                FirebaseAuth.instanceFor(app: second).userChanges();

            subscription = stream.listen(
              expectAsync1(
                (User? user) {},
                reason: 'Stream should only call once',
              ),
            );

            await Future.delayed(const Duration(seconds: 2));
          }, skip: defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.windows,);

          test(
              'calls callback with the current user and when user state changes',
              () async {
            await ensureSignedIn(testEmail);

            Stream<User?> stream = FirebaseAuth.instance.userChanges();
            int call = 0;

            subscription = stream.listen(
              expectAsync1(
                (User? user) {
                  call++;
                  if (call == 1) {
                    expect(user!.displayName, isNull); // initial user
                  } else if (call == 2) {
                    expect(
                      user!.displayName,
                      equals('updatedName'),
                    ); // updated profile
                  } else {
                    fail('Should not have been called');
                  }
                },
                count: 2,
                reason: 'Stream should only have been called 2 times',
              ),
            );

            await FirebaseAuth.instance.currentUser!
                .updateDisplayName('updatedName');

            expect(
              FirebaseAuth.instance.currentUser!.displayName,
              equals('updatedName'),
            );
          });
        },
        skip: !kIsWeb && (Platform.isWindows || Platform.isMacOS),
      );

      group('test all stream listeners', () {
        Matcher containsExactlyThreeUsers() => predicate<List>(
              (list) => list.whereType<User>().length == 3,
              'a list containing exactly 3 User instances',
            );
        test('create, cancel and reopen all user event stream handlers',
            () async {
          final auth = FirebaseAuth.instance;
          final events = [];
          final streamHandler = events.add;

          StreamSubscription<User?> userChanges =
              auth.userChanges().listen(streamHandler);

          StreamSubscription<User?> authStateChanges =
              auth.authStateChanges().listen(streamHandler);

          StreamSubscription<User?> idTokenChanges =
              auth.idTokenChanges().listen(streamHandler);

          await userChanges.cancel();
          await authStateChanges.cancel();
          await idTokenChanges.cancel();

          userChanges = auth.userChanges().listen(streamHandler);
          authStateChanges = auth.authStateChanges().listen(streamHandler);
          idTokenChanges = auth.idTokenChanges().listen(streamHandler);

          await auth.signInWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          );

          expect(events, containsExactlyThreeUsers());
        });
      });

      group('currentUser', () {
        test('should return currentUser', () async {
          await ensureSignedIn(testEmail);
          var currentUser = FirebaseAuth.instance.currentUser;
          expect(currentUser, isA<User>());
        });
      });

      group(
        'applyActionCode',
        () {
          test('throws if invalid code', () async {
            try {
              await FirebaseAuth.instance.applyActionCode('!!!!!!');
              fail('Should have thrown');
            } on FirebaseException catch (e) {
              expect(e.code, equals('invalid-action-code'));
            } catch (e) {
              fail(e.toString());
            }
          });
        },
        skip: !kIsWeb && Platform.isWindows,
      );

      group(
        'checkActionCode()',
        () {
          test('throws on invalid code', () async {
            try {
              await FirebaseAuth.instance.checkActionCode('!!!!!!');
              fail('Should have thrown');
            } on FirebaseException catch (e) {
              expect(e.code, equals('invalid-action-code'));
            } catch (e) {
              fail(e.toString());
            }
          });
        },
        skip: !kIsWeb && Platform.isWindows,
      );

      group(
        'confirmPasswordReset()',
        () {
          test('throws on invalid code', () async {
            try {
              await FirebaseAuth.instance.confirmPasswordReset(
                code: '!!!!!!',
                newPassword: 'thingamajig',
              );
              fail('Should have thrown');
            } on FirebaseException catch (e) {
              expect(e.code, equals('invalid-action-code'));
            } catch (e) {
              fail(e.toString());
            }
          });
        },
        skip: !kIsWeb && Platform.isWindows,
      );

      group('createUserWithEmailAndPassword', () {
        test('should create a user with an email and password', () async {
          var email = generateRandomEmail();

          Function successCallback = (UserCredential newUserCredential) async {
            expect(newUserCredential.user, isA<User>());
            final newUser = newUserCredential.user;

            expect(newUser?.uid, isA<String>());
            expect(newUser?.email, equals(email));
            expect(newUser?.emailVerified, isFalse);
            expect(newUser?.isAnonymous, isFalse);
            expect(
              newUser?.uid,
              equals(FirebaseAuth.instance.currentUser!.uid),
            );

            var additionalUserInfo = newUserCredential.additionalUserInfo;
            expect(additionalUserInfo, isA<AdditionalUserInfo>());
            if (!kIsWeb && Platform.isWindows) {
              // Skip because isNewUser is always false on Windows
            } else {
              expect(additionalUserInfo?.isNewUser, isTrue);
            }

            await FirebaseAuth.instance.currentUser?.delete();
          };

          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                email: email,
                password: testPassword,
              )
              .then(successCallback as Function(UserCredential));
        });

        test('fails if creating a user which already exists', () async {
          await ensureSignedIn(testEmail);
          try {
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: testEmail,
              password: '123456',
            );
            fail('Should have thrown FirebaseAuthException');
          } on FirebaseAuthException catch (e) {
            expect(e.code, equals('email-already-in-use'));
          } catch (e) {
            fail(e.toString());
          }
        });

        test('fails if creating a user with an invalid email', () async {
          await ensureSignedIn(testEmail);
          try {
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: '!!!!!',
              password: '123456',
            );
            fail('Should have thrown FirebaseAuthException');
          } on FirebaseAuthException catch (e) {
            expect(e.code, equals('invalid-email'));
          } catch (e) {
            fail(e.toString());
          }
        });

        test('fails if creating a user if providing a weak password', () async {
          await ensureSignedIn(testEmail);
          try {
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: generateRandomEmail(),
              password: '1',
            );
            fail('Should have thrown FirebaseAuthException');
          } on FirebaseAuthException catch (e) {
            expect(e.code, equals('weak-password'));
          } catch (e) {
            fail(e.toString());
          }
        });
      });

      group('isSignInWithEmailLink()', () {
        test('should return true or false', () {
          const emailLink1 =
              'https://www.example.com/action?mode=signIn&oobCode=oobCode';
          const emailLink2 =
              'https://www.example.com/action?mode=verifyEmail&oobCode=oobCode';
          const emailLink3 = 'https://www.example.com/action?mode=signIn';
          const emailLink4 =
              'https://x59dg.app.goo.gl/?link=https://rnfirebase-b9ad4.firebaseapp.com/__/auth/action?apiKey%3Dfoo%26mode%3DsignIn%26oobCode%3Dbar';

          expect(
            FirebaseAuth.instance.isSignInWithEmailLink(emailLink1),
            equals(true),
          );
          expect(
            FirebaseAuth.instance.isSignInWithEmailLink(emailLink2),
            equals(false),
          );
          expect(
            FirebaseAuth.instance.isSignInWithEmailLink(emailLink3),
            equals(false),
          );
          expect(
            FirebaseAuth.instance.isSignInWithEmailLink(emailLink4),
            equals(true),
          );
        });
      });

      group(
        'sendPasswordResetEmail()',
        () {
          test(
            'should not error',
            () async {
              var email = generateRandomEmail();

              try {
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email,
                  password: testPassword,
                );

                await FirebaseAuth.instance
                    .sendPasswordResetEmail(email: email);
                await FirebaseAuth.instance.currentUser!.delete();
              } catch (e) {
                await FirebaseAuth.instance.currentUser!.delete();
                fail(e.toString());
              }
            },
            skip: !kIsWeb && Platform.isMacOS,
          );

          test('fails if the user could not be found', () async {
            try {
              await FirebaseAuth.instance
                  .sendPasswordResetEmail(email: 'does-not-exist@bar.com');
              fail('Should have thrown');
            } on FirebaseAuthException catch (e) {
              expect(e.code, equals('user-not-found'));
            } catch (e) {
              fail(e.toString());
            }
          });
        },
        skip: !kIsWeb && Platform.isWindows,
      );

      group(
        'sendSignInLinkToEmail()',
        () {
          test('should send email successfully', () async {
            const email = 'email-signin-test@example.com';
            const continueUrl = 'http://action-code-test.com';

            await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: email,
              password: testPassword,
            );

            final actionCodeSettings = ActionCodeSettings(
              url: continueUrl,
              handleCodeInApp: true,
            );

            await FirebaseAuth.instance.sendSignInLinkToEmail(
              email: email,
              actionCodeSettings: actionCodeSettings,
            );

            // Confirm with the emulator that it triggered an email sending code.
            final oobCode = await emulatorOutOfBandCode(
              email,
              EmulatorOobCodeType.emailSignIn,
            );
            expect(oobCode, isNotNull);
            expect(oobCode?.email, email);
            expect(oobCode?.type, EmulatorOobCodeType.emailSignIn);

            // Confirm the continue url was passed through to backend correctly.
            final url = Uri.parse(oobCode!.oobLink!);
            expect(
              url.queryParameters['continueUrl'],
              Uri.encodeFull(continueUrl),
            );
          });
        },
        skip: !kIsWeb && (Platform.isWindows || Platform.isMacOS),
      );

      group('languageCode', () {
        test('should change the language code', () async {
          await FirebaseAuth.instance.setLanguageCode('en');

          expect(FirebaseAuth.instance.languageCode, equals('en'));
        });

        test(
          'should allow null value and default the device language code',
          () async {
            await FirebaseAuth.instance.setLanguageCode(null);

            expect(
              FirebaseAuth.instance.languageCode,
              isNotNull,
            ); // default to the device language or the Firebase projects default language
          },
          skip: kIsWeb || defaultTargetPlatform == TargetPlatform.macOS,
        );

        test(
          'should allow null value and set to null',
          () async {
            // Isn't possible anymore to set the language code to null
            // See API: https://firebase.google.com/docs/reference/js/auth.md?_gl=1*120kqub*_up*MQ..*_ga*NTg2MzgzNDU0LjE3MDc5MTYxMjI.*_ga_CW55HF8NVT*MTcwNzkxNjEyMi4xLjAuMTcwNzkxNjEyMi4wLjAuMA..#usedevicelanguage_2a61ea7
            // Effectively will set the language code to the device language.
            await FirebaseAuth.instance.setLanguageCode(null);
            // This will return the device language now. e.g. "en-GB"
            expect(FirebaseAuth.instance.languageCode, null);
          },
          skip: true,
        );
      });

      group(
        'setPersistence()',
        () {
          test(
            'throw an unimplemented error',
            () async {
              try {
                await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
                fail('Should have thrown');
              } catch (e) {
                expect(e, isInstanceOf<UnimplementedError>());
              }
            },
            skip: kIsWeb || defaultTargetPlatform == TargetPlatform.macOS,
          );

          test(
            'should set persistence',
            () async {
              try {
                await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
              } catch (e) {
                fail('unexpected error thrown');
              }
            },
            skip: !kIsWeb,
          );
        },
        skip: !kIsWeb && Platform.isWindows,
      );

      group('signInAnonymously()', () {
        test(
          'should sign in anonymously',
          () async {
            Future successCallback(UserCredential currentUserCredential) async {
              final currentUser = currentUserCredential.user;

              expect(currentUser, isA<User>());
              expect(currentUser?.uid, isA<String>());
              expect(currentUser?.email, isNull);
              expect(currentUser?.isAnonymous, isTrue);
              expect(
                currentUser?.uid,
                equals(FirebaseAuth.instance.currentUser!.uid),
              );

              var additionalUserInfo = currentUserCredential.additionalUserInfo;
              expect(additionalUserInfo, isInstanceOf<Object>());

              await FirebaseAuth.instance.signOut();
            }

            final userCred = await FirebaseAuth.instance.signInAnonymously();
            await successCallback(userCred);
          },
          skip: !kIsWeb && (Platform.isWindows || Platform.isMacOS),
        );
      });

      group('signInWithCredential()', () {
        test(
          'should login with email and password',
          () async {
            final credential = EmailAuthProvider.credential(
              email: testEmail,
              password: testPassword,
            );
            await FirebaseAuth.instance
                .signInWithCredential(credential)
                .then(commonSuccessCallback);
          },
          skip: !kIsWeb && (Platform.isWindows || Platform.isMacOS),
        );

        test('throws if login user is disabled', () async {
          final credential = EmailAuthProvider.credential(
            email: testDisabledEmail,
            password: testPassword,
          );

          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            fail('Should have thrown');
          } on FirebaseException catch (e) {
            expect(e.code, equals('user-disabled'));
            expect(
              e.message,
              equals(
                'The user account has been disabled by an administrator.',
              ),
            );
          } catch (e) {
            fail(e.toString());
          }
        });

        test('throws if login password is incorrect', () async {
          var credential = EmailAuthProvider.credential(
            email: testEmail,
            password: 'sowrong',
          );
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            fail('Should have thrown');
          } on FirebaseException catch (e) {
            expect(e.code, equals('wrong-password'));
            expect(
              e.message,
              equals(
                'The password is invalid or the user does not have a password.',
              ),
            );
          } catch (e) {
            fail(e.toString());
          }
        });

        test('throws if login user is not found', () async {
          final credential = EmailAuthProvider.credential(
            email: generateRandomEmail(),
            password: testPassword,
          );
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            fail('Should have thrown');
          } on FirebaseException catch (e) {
            expect(e.code, equals('user-not-found'));
            expect(
              e.message,
              equals(
                'There is no user record corresponding to this identifier. The user may have been deleted.',
              ),
            );
          } catch (e) {
            fail(e.toString());
          }
        });

        test(
            'throw Exception when using incorrect auth details with GoogleAuthProvider',
            () async {
          final credential = GoogleAuthProvider.credential(
            idToken: 'incorrect idToken',
          );

          await expectLater(
            FirebaseAuth.instance.signInWithCredential(credential),
            throwsA(
              isA<FirebaseAuthException>().having(
                (e) => e.code,
                'code',
                contains('invalid-credential'),
              ),
            ),
          );

          final credential2 = GoogleAuthProvider.credential(
            accessToken: 'incorrect accessToken',
          );

          await expectLater(
            FirebaseAuth.instance.signInWithCredential(credential2),
            throwsA(
              isA<FirebaseAuthException>(),
              // Live project has this error code, emulator throws "internal-error"
              // .having(
              //   (e) => e.code,
              //   'code',
              //   contains('invalid-credential'),
              // ),
            ),
          );
        });
      });

      group(
        'signInWithCustomToken()',
        () {
          test('signs in with custom auth token', () async {
            final userCredential =
                await FirebaseAuth.instance.signInAnonymously();
            final uid = userCredential.user!.uid;
            final claims = {
              'roles': [
                {'role': 'member'},
                {'role': 'admin'},
              ],
            };

            await ensureSignedOut();

            expect(FirebaseAuth.instance.currentUser, null);

            final customToken = emulatorCreateCustomToken(uid, claims: claims);

            final customTokenUserCredential =
                await FirebaseAuth.instance.signInWithCustomToken(customToken);

            expect(customTokenUserCredential.user!.uid, equals(uid));
            expect(FirebaseAuth.instance.currentUser!.uid, equals(uid));

            final idTokenResult =
                await FirebaseAuth.instance.currentUser!.getIdTokenResult();

            expect(idTokenResult.claims!['roles'], isA<List>());
            expect(idTokenResult.claims!['roles'][0], isA<Map>());
            expect(idTokenResult.claims!['roles'][0]['role'], 'member');
          });
        },
        skip: !kIsWeb && (Platform.isWindows || Platform.isMacOS),
      );

      group('signInWithEmailAndPassword()', () {
        test('should login with email and password', () async {
          await FirebaseAuth.instance
              .signInWithEmailAndPassword(
                email: testEmail,
                password: testPassword,
              )
              .then(commonSuccessCallback);
        });

        test('throws if login user is disabled', () async {
          try {
            await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: testDisabledEmail,
              password: testPassword,
            );
            fail('Should have thrown');
          } on FirebaseException catch (e) {
            expect(e.code, equals('user-disabled'));
            expect(
              e.message,
              equals(
                'The user account has been disabled by an administrator.',
              ),
            );
          } catch (e) {
            fail(e.toString());
          }
        });

        test('throws if login password is incorrect', () async {
          try {
            await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: testEmail,
              password: 'sowrong',
            );
            fail('Should have thrown');
          } on FirebaseException catch (e) {
            expect(e.code, equals('wrong-password'));
            expect(
              e.message,
              equals(
                'The password is invalid or the user does not have a password.',
              ),
            );
          } catch (e) {
            fail(e.toString());
          }
        });

        test('throws if login user is not found', () async {
          try {
            await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: generateRandomEmail(),
              password: testPassword,
            );
            fail('Should have thrown');
          } on FirebaseException catch (e) {
            expect(e.code, equals('user-not-found'));
            expect(
              e.message,
              equals(
                'There is no user record corresponding to this identifier. The user may have been deleted.',
              ),
            );
          } catch (e) {
            fail(e.toString());
          }
        });
        test(
          'should not throw error when app is deleted and reinit with same app name',
          () async {
            try {
              const appName = 'SecondaryApp';

              final app = await Firebase.initializeApp(
                name: appName,
                options: DefaultFirebaseOptions.currentPlatform,
              );

              var auth1 = FirebaseAuth.instanceFor(app: app);

              await auth1.signInWithEmailAndPassword(
                email: testEmail,
                password: testPassword,
              );

              await app.delete();

              final app2 = await Firebase.initializeApp(
                name: appName,
                options: DefaultFirebaseOptions.currentPlatform,
              );

              final auth2 = FirebaseAuth.instanceFor(app: app2);

              await auth2.signInWithEmailAndPassword(
                email: testEmail,
                password: testPassword,
              );
            } catch (e) {
              fail(e.toString());
            }
          },
          // TODO(russellwheatley): this is crashing iOS/macOS app (reinit app), but does not when running as app.
          skip: defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS,
        );
      });

      group('signOut()', () {
        test('should sign out', () async {
          await ensureSignedIn(testEmail);
          expect(FirebaseAuth.instance.currentUser, isA<User>());
          await FirebaseAuth.instance.signOut();
          expect(FirebaseAuth.instance.currentUser, isNull);
        });
      });

      group(
        'verifyPasswordResetCode()',
        () {
          test('throws on invalid code', () async {
            try {
              await FirebaseAuth.instance.verifyPasswordResetCode('!!!!!!');
              fail('Should have thrown');
            } on FirebaseException catch (e) {
              expect(e.code, equals('invalid-action-code'));
            } catch (e) {
              fail(e.toString());
            }
          });
        },
        skip: defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.windows,
      );

      group(
        'verifyPhoneNumber()',
        () {
          test('should fail with an invalid phone number', () async {
            Future<Exception> getError() async {
              Completer completer = Completer<FirebaseAuthException>();

              unawaited(
                FirebaseAuth.instance.verifyPhoneNumber(
                  phoneNumber: 'foo',
                  verificationCompleted: (PhoneAuthCredential credential) {
                    return completer.completeError(
                      Exception('Should not have been called'),
                    );
                  },
                  verificationFailed: (FirebaseAuthException e) {
                    completer.complete(e);
                  },
                  codeSent: (String verificationId, int? resetToken) {
                    return completer.completeError(
                      Exception('Should not have been called'),
                    );
                  },
                  codeAutoRetrievalTimeout: (String foo) {
                    return completer.completeError(
                      Exception('Should not have been called'),
                    );
                  },
                ),
              );

              return completer.future as FutureOr<Exception>;
            }

            Exception e = await getError();
            expect(e, isA<FirebaseAuthException>());
            FirebaseAuthException exception = e as FirebaseAuthException;
            expect(exception.code, equals('invalid-phone-number'));
          });

          test(
            'should auto verify phone number',
            () async {
              String testPhoneNumber = '+447444555666';
              String testSmsCode = '123456';
              await FirebaseAuth.instance.signInAnonymously();

              Future<PhoneAuthCredential> getCredential() async {
                final completer = Completer<PhoneAuthCredential>();

                unawaited(
                  FirebaseAuth.instance.verifyPhoneNumber(
                    phoneNumber: testPhoneNumber,
                    // ignore: invalid_use_of_visible_for_testing_member
                    autoRetrievedSmsCodeForTesting: testSmsCode,
                    verificationCompleted: (PhoneAuthCredential credential) {
                      if (credential.smsCode != testSmsCode) {
                        return completer
                            .completeError(Exception('SMS code did not match'));
                      }

                      completer.complete(credential);
                    },
                    verificationFailed: (FirebaseException e) {
                      return completer.completeError(
                        Exception('Should not have been called'),
                      );
                    },
                    codeSent: (String verificationId, int? resetToken) {
                      return completer.completeError(
                        Exception('Should not have been called'),
                      );
                    },
                    codeAutoRetrievalTimeout: (String foo) {
                      return completer.completeError(
                        Exception('Should not have been called'),
                      );
                    },
                  ),
                );

                return completer.future;
              }

              PhoneAuthCredential credential = await getCredential();
              expect(credential, isA<PhoneAuthCredential>());
            },
            skip: kIsWeb || defaultTargetPlatform != TargetPlatform.android,
          );
        },
        skip: defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.windows ||
            kIsWeb,
      );

      group('setSettings()', () {
        test(
          'throws argument error if phoneNumber & smsCode have not been set simultaneously',
          () async {
            String message =
                "The [smsCode] and the [phoneNumber] must both be either 'null' or a 'String''.";
            await expectLater(
              FirebaseAuth.instance.setSettings(phoneNumber: '123456'),
              throwsA(
                isA<ArgumentError>()
                    .having((e) => e.message, 'message', contains(message)),
              ),
            );

            await expectLater(
              FirebaseAuth.instance.setSettings(smsCode: '123456'),
              throwsA(
                isA<ArgumentError>()
                    .having((e) => e.message, 'message', contains(message)),
              ),
            );
          },
          skip: kIsWeb || defaultTargetPlatform != TargetPlatform.android,
        );
      });

      group(
        'tenantId',
        () {
          test('User associated with the tenantId correctly', () async {
            // tenantId created in the GCP console
            const String tenantId = 'auth-tenant-test-xukxg';
            // created User on GCP console associated with the above tenantId
            final userCredential =
                await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: 'test-tenant@email.com',
              password: 'fake-password',
            );

            expect(userCredential.user!.tenantId, tenantId);
          });
          // todo(russellwheatley85): get/set tenantId and authenticating user via auth emulator is not possible at the moment.
        },
        skip: true,
      );

      group(
        'initializeRecaptchaConfig',
        () {
          test('initializeRecaptchaConfig completes without throwing',
              () async {
            // Skipping this test as initializeRecaptchaConfig is not supported
            // by the Firebase emulator suite.
            try {
              await FirebaseAuth.instance.initializeRecaptchaConfig();
            } catch (e) {
              fail('Should not have thrown: $e');
            }
          });
        },
        skip: true,
      );

      group('validatePassword()', () {
        const String validPassword =
            'Password123!'; // For password policy impl testing
        const String invalidPassword = 'Pa1!';
        const String invalidPassword2 = 'password123!';
        const String invalidPassword3 = 'PASSWORD123!';
        const String invalidPassword4 = 'password!';
        const String invalidPassword5 = 'Password123';

        test('should validate password that is correct', () async {
          final PasswordValidationStatus status = await FirebaseAuth.instance
              .validatePassword(FirebaseAuth.instance, validPassword);
          expect(status.isValid, isTrue);
          expect(status.meetsMinPasswordLength, isTrue);
          expect(status.meetsMaxPasswordLength, isTrue);
          expect(status.meetsLowercaseRequirement, isTrue);
          expect(status.meetsUppercaseRequirement, isTrue);
          expect(status.meetsDigitsRequirement, isTrue);
          expect(status.meetsSymbolsRequirement, isTrue);
        });

        test('should not validate a password that is too short', () async {
          final PasswordValidationStatus status = await FirebaseAuth.instance
              .validatePassword(FirebaseAuth.instance, invalidPassword);
          expect(status.isValid, isFalse);
          expect(status.meetsMinPasswordLength, isFalse);
        });

        test('should not validate a password that has no uppercase characters',
            () async {
          final PasswordValidationStatus status = await FirebaseAuth.instance
              .validatePassword(FirebaseAuth.instance, invalidPassword2);
          expect(status.isValid, isFalse);
          expect(status.meetsUppercaseRequirement, isFalse);
        });

        test('should not validate a password that has no lowercase characters',
            () async {
          final PasswordValidationStatus status = await FirebaseAuth.instance
              .validatePassword(FirebaseAuth.instance, invalidPassword3);
          expect(status.isValid, isFalse);
        });

        test('should not validate a password that has no digits', () async {
          final PasswordValidationStatus status = await FirebaseAuth.instance
              .validatePassword(FirebaseAuth.instance, invalidPassword4);
          expect(status.isValid, isFalse);
          expect(status.meetsDigitsRequirement, isFalse);
        });

        test('should not validate a password that has no symbols', () async {
          final PasswordValidationStatus status = await FirebaseAuth.instance
              .validatePassword(FirebaseAuth.instance, invalidPassword5);
          expect(status.isValid, isFalse);
          expect(status.meetsSymbolsRequirement, isFalse);
        });

        test('should throw an exception if the password is empty', () async {
          try {
            await FirebaseAuth.instance.validatePassword(
              FirebaseAuth.instance,
              '',
            );
          } catch (e) {
            expect(
              e,
              isA<FirebaseAuthException>().having(
                (e) => e.code,
                'code',
                equals('invalid-password'),
              ),
            );
          }
        });

        test('should throw an exception if the password is null', () async {
          try {
            await FirebaseAuth.instance.validatePassword(
              FirebaseAuth.instance,
              null,
            );
          } catch (e) {
            expect(
              e,
              isA<FirebaseAuthException>().having(
                (e) => e.code,
                'code',
                equals('invalid-password'),
              ),
            );
          }
        });
      });
    },
    // macOS skipped because it needs keychain sharing entitlement. See: https://github.com/firebase/flutterfire/issues/9538
    skip: defaultTargetPlatform == TargetPlatform.macOS,
  );
}
