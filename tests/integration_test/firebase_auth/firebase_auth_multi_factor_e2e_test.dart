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

  group(
    '$MultiFactor',
    () {
      String email = generateRandomEmail();

      group('multiFactor', () {
        test('should return an empty enrolled factor', () async {
          // Setup
          User? user;
          UserCredential userCredential;

          userCredential =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: testPassword,
          );
          user = userCredential.user;

          final multiFactor = user!.multiFactor;

          // Assertions
          expect((await multiFactor.getEnrolledFactors()).length, 0);
        });
      });

      group('session', () {
        test('should return an empty enrolled factor', () async {
          // Setup
          User? user;
          UserCredential userCredential;

          userCredential =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: testPassword,
          );
          user = userCredential.user;

          final multiFactor = user!.multiFactor;

          final session = await multiFactor.getSession();

          // Assertions
          expect(session.id, isNotNull);
        });
      });

      group('enrollFactor', () {
        test(
          'should enroll and unenroll factor',
          () async {
            String testPhoneNumber = '+441444555666';
            User? user;
            UserCredential userCredential;

            userCredential =
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: email,
              password: testPassword,
            );
            user = userCredential.user;

            await user!.sendEmailVerification();
            final oobCode = (await emulatorOutOfBandCode(
              email,
              EmulatorOobCodeType.verifyEmail,
            ))!;

            await emulatorVerifyEmail(
              oobCode.oobCode!,
            );

            final multiFactor = user.multiFactor;
            final session = await multiFactor.getSession();

            Future<String> getCredential() async {
              Completer completer = Completer<String>();

              unawaited(
                FirebaseAuth.instance.verifyPhoneNumber(
                  phoneNumber: testPhoneNumber,
                  multiFactorSession: session,
                  verificationCompleted: (PhoneAuthCredential credential) {
                    if (!completer.isCompleted) {
                      return completer.completeError(
                        Exception(
                          'verificationCompleted should not have been called',
                        ),
                      );
                    }
                  },
                  verificationFailed: (FirebaseException e) {
                    if (!completer.isCompleted) {
                      return completer.completeError(
                        Exception(
                          'verificationFailed should not have been called',
                        ),
                      );
                    }
                  },
                  codeSent: (String verificationId, int? resetToken) {
                    completer.complete(verificationId);
                  },
                  codeAutoRetrievalTimeout: (String foo) {
                    if (!completer.isCompleted) {
                      return completer.completeError(
                        Exception(
                          'codeAutoRetrievalTimeout should not have been called',
                        ),
                      );
                    }
                  },
                ),
              );

              return completer.future as FutureOr<String>;
            }

            final verificationId = await getCredential();

            final smsCode = await emulatorPhoneVerificationCode(
              testPhoneNumber,
            );

            final credential = PhoneAuthProvider.credential(
              verificationId: verificationId,
              smsCode: smsCode!,
            );

            expect(credential, isA<PhoneAuthCredential>());

            await user.multiFactor.enroll(
              PhoneMultiFactorGenerator.getAssertion(
                credential,
              ),
              displayName: 'My phone number',
            );

            final enrolledFactors = await multiFactor.getEnrolledFactors();

            // Assertions
            expect(enrolledFactors.length, 1);
            expect(enrolledFactors.first.displayName, 'My phone number');

            await user.multiFactor.unenroll(
              multiFactorInfo: enrolledFactors.first,
            );

            final enrolledFactorsAfter = await multiFactor.getEnrolledFactors();

            // Assertions
            expect(enrolledFactorsAfter.length, 0);
          },
          skip: kIsWeb || defaultTargetPlatform != TargetPlatform.android,
        );

        test(
          'should not enroll factor if email not verifed',
          () async {
            String testPhoneNumber = '+448444555666';
            User? user;
            UserCredential userCredential;
            final email = generateRandomEmail();

            userCredential =
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: email,
              password: testPassword,
            );
            user = userCredential.user;

            final multiFactor = user!.multiFactor;
            final session = await multiFactor.getSession();

            Future<Exception> getCredential() async {
              Completer completer = Completer<Exception>();

              unawaited(
                FirebaseAuth.instance.verifyPhoneNumber(
                  phoneNumber: testPhoneNumber,
                  multiFactorSession: session,
                  verificationCompleted: (PhoneAuthCredential credential) {
                    if (!completer.isCompleted) {
                      return completer.completeError(
                        Exception('Should not have been called'),
                      );
                    }
                  },
                  verificationFailed: (FirebaseException e) {
                    completer.complete(e);
                  },
                  codeSent: (String verificationId, int? resetToken) {
                    if (!completer.isCompleted) {
                      return completer.completeError(
                        Exception('Should not have been called'),
                      );
                    }
                  },
                  codeAutoRetrievalTimeout: (String foo) {
                    if (!completer.isCompleted) {
                      return completer.completeError(
                        Exception('Should not have been called'),
                      );
                    }
                  },
                ),
              );

              return completer.future as FutureOr<Exception>;
            }

            final exception = await getCredential();

            expect(exception, isNotNull);
          },
        );
      });

      group('signIn', () {
        test(
          'should sign in with 2 factors',
          () async {
            String testPhoneNumber = '+449444555666';
            User? user;
            UserCredential userCredential;

            userCredential =
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: email,
              password: testPassword,
            );
            user = userCredential.user;

            await user!.sendEmailVerification();
            final oobCode = (await emulatorOutOfBandCode(
              email,
              EmulatorOobCodeType.verifyEmail,
            ))!;

            await emulatorVerifyEmail(
              oobCode.oobCode!,
            );

            final multiFactor = user.multiFactor;
            final session = await multiFactor.getSession();

            Future<String> getCredential() async {
              Completer completer = Completer<String>();

              unawaited(
                FirebaseAuth.instance.verifyPhoneNumber(
                  phoneNumber: testPhoneNumber,
                  multiFactorSession: session,
                  verificationCompleted: (PhoneAuthCredential credential) {
                    if (!completer.isCompleted) {
                      return completer.completeError(
                        Exception('Should not have been called'),
                      );
                    }
                  },
                  verificationFailed: (FirebaseException e) {
                    if (!completer.isCompleted) {
                      return completer.completeError(
                        Exception('Should not have been called'),
                      );
                    }
                  },
                  codeSent: (String verificationId, int? resetToken) {
                    completer.complete(verificationId);
                  },
                  codeAutoRetrievalTimeout: (String foo) {
                    if (!completer.isCompleted) {
                      return completer.completeError(
                        Exception('Should not have been called'),
                      );
                    }
                  },
                ),
              );

              return completer.future as FutureOr<String>;
            }

            final verificationId = await getCredential();

            final smsCode = await emulatorPhoneVerificationCode(
              testPhoneNumber,
            );

            final credential = PhoneAuthProvider.credential(
              verificationId: verificationId,
              smsCode: smsCode!,
            );

            expect(credential, isA<PhoneAuthCredential>());

            await user.multiFactor.enroll(
              PhoneMultiFactorGenerator.getAssertion(
                credential,
              ),
              displayName: 'My phone number',
            );

            await FirebaseAuth.instance.signOut();

            Exception? exception;

            try {
              userCredential =
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: email,
                password: testPassword,
              );
            } catch (e) {
              exception = e as Exception;
            }

            expect(exception, isA<FirebaseAuthMultiFactorException>());

            if (exception == null) {
              throw Exception('Should not be null');
            }

            final FirebaseAuthMultiFactorException multiFactorException =
                exception as FirebaseAuthMultiFactorException;

            Future<String> getCredentialSignIn() async {
              Completer completer = Completer<String>();

              unawaited(
                FirebaseAuth.instance.verifyPhoneNumber(
                  multiFactorInfo: multiFactorException.resolver.hints.first
                      as PhoneMultiFactorInfo,
                  multiFactorSession: multiFactorException.resolver.session,
                  verificationCompleted: (PhoneAuthCredential credential) {
                    if (!completer.isCompleted) {
                      return completer.completeError(
                        Exception('Should not have been called'),
                      );
                    }
                  },
                  verificationFailed: (FirebaseException e) {
                    if (!completer.isCompleted) {
                      return completer.completeError(
                        Exception('Should not have been called'),
                      );
                    }
                  },
                  codeSent: (String verificationId, int? resetToken) {
                    completer.complete(verificationId);
                  },
                  codeAutoRetrievalTimeout: (String foo) {
                    if (!completer.isCompleted) {
                      return completer.completeError(
                        Exception('Should not have been called'),
                      );
                    }
                  },
                ),
              );

              return completer.future as FutureOr<String>;
            }

            final verificationIdSignIn = await getCredentialSignIn();

            final smsCodeSignIn = await emulatorPhoneVerificationCode(
              testPhoneNumber,
            );

            final credentialSignIn = PhoneAuthProvider.credential(
              verificationId: verificationIdSignIn,
              smsCode: smsCodeSignIn!,
            );

            expect(credentialSignIn, isA<PhoneAuthCredential>());

            await exception.resolver.resolveSignIn(
              PhoneMultiFactorGenerator.getAssertion(
                credentialSignIn,
              ),
            );

            expect(FirebaseAuth.instance.currentUser, isNotNull);
          },
        );
      });
    },
    skip: kIsWeb || defaultTargetPlatform != TargetPlatform.android,
  );
}
