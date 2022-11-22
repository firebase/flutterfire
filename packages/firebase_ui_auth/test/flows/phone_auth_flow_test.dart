// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' hide PhoneAuthProvider;
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:mockito/mockito.dart';

import '../test_utils.dart';

void main() {
  late PhoneAuthProvider provider;
  late MockAuth auth;
  late MockListener listener;

  setUp(() {
    auth = MockAuth();
    listener = MockListener();

    provider = PhoneAuthProvider();
    provider.auth = auth;
    provider.authListener = listener;
  });

  group('PhoneAuthProvider', () {
    test('has correct provider id', () {
      expect(provider.providerId, 'phone');
    });

    group('#sendVerificationCode', () {
      test('calls onSMSCodeRequested', () {
        provider.sendVerificationCode(
          phoneNumber: '+123456789',
          action: AuthAction.signIn,
        );

        final invocation = verify(listener.onSMSCodeRequested('+123456789'));
        expect(invocation.callCount, 1);
      });

      test('calls FirebaseAuth#verifyPhoneNumber', () async {
        provider.sendVerificationCode(
          phoneNumber: '+123456789',
          action: AuthAction.signIn,
        );

        final invocation = verify(
          auth.verifyPhoneNumber(
            phoneNumber: captureAnyNamed('phoneNumber'),
            verificationCompleted: anyNamed('verificationCompleted'),
            verificationFailed: anyNamed('verificationFailed'),
            codeSent: anyNamed('codeSent'),
            codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
          ),
        );

        await untilCalled(listener.onSMSCodeRequested(any));

        expect(invocation.callCount, 1);
        expect(invocation.captured.first, '+123456789');
      });

      test('calls onCodeSent when code is sent', () async {
        provider.sendVerificationCode(
          phoneNumber: '+123456789',
          action: AuthAction.signIn,
        );

        final invocation = verify(
          auth.verifyPhoneNumber(
            phoneNumber: anyNamed('phoneNumber'),
            verificationCompleted: anyNamed('verificationCompleted'),
            verificationFailed: anyNamed('verificationFailed'),
            codeSent: captureAnyNamed('codeSent'),
            codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
          ),
        );

        await untilCalled(listener.onSMSCodeRequested(any));

        final onCodeSent = invocation.captured[0];
        onCodeSent('verificationId');

        final onCodeSendInvocation = verify(listener.onCodeSent(captureAny));

        expect(onCodeSendInvocation.callCount, 1);
        expect(onCodeSendInvocation.captured, ['verificationId']);
      });

      test(
        'calls onVerificationCompleted when verification is complete',
        () async {
          provider.sendVerificationCode(
            phoneNumber: '+123456789',
            action: AuthAction.signIn,
          );

          final credential = MockPhoneCredential();

          final invocation = verify(
            auth.verifyPhoneNumber(
              phoneNumber: anyNamed('phoneNumber'),
              verificationCompleted: captureAnyNamed('verificationCompleted'),
              verificationFailed: anyNamed('verificationFailed'),
              codeSent: anyNamed('codeSent'),
              codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
            ),
          );

          await untilCalled(listener.onSMSCodeRequested(any));

          final onVerificationCompleted = invocation.captured[0];
          onVerificationCompleted(credential);

          final onVerificationCompletedInvocation = verify(
            listener.onVerificationCompleted(captureAny),
          );

          expect(onVerificationCompletedInvocation.callCount, 1);
          expect(onVerificationCompletedInvocation.captured, [credential]);
        },
      );

      test('calls onError if autoresolution timed out', () async {
        provider.sendVerificationCode(
          phoneNumber: '+123456789',
          action: AuthAction.signIn,
        );

        final invocation = verify(
          auth.verifyPhoneNumber(
            phoneNumber: anyNamed('phoneNumber'),
            verificationCompleted: anyNamed('verificationCompleted'),
            verificationFailed: anyNamed('verificationFailed'),
            codeSent: anyNamed('codeSent'),
            codeAutoRetrievalTimeout: captureAnyNamed(
              'codeAutoRetrievalTimeout',
            ),
          ),
        );

        await untilCalled(listener.onSMSCodeRequested(any));

        final timeout = invocation.captured[0];
        timeout('+123456789');

        final onErrorInvocation = verify(listener.onError(captureAny));

        expect(onErrorInvocation.callCount, 1);
        expect(
          onErrorInvocation.captured.first,
          isA<AutoresolutionFailedException>(),
        );
      });

      test('calls onError if verification failed', () async {
        provider.sendVerificationCode(
          phoneNumber: '+123456789',
          action: AuthAction.signIn,
        );

        final exception = TestException();

        final invocation = verify(
          auth.verifyPhoneNumber(
            phoneNumber: anyNamed('phoneNumber'),
            verificationCompleted: anyNamed('verificationCompleted'),
            verificationFailed: captureAnyNamed('verificationFailed'),
            codeSent: anyNamed('codeSent'),
            codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
          ),
        );

        await untilCalled(listener.onSMSCodeRequested(any));

        final onError = invocation.captured[0];
        onError(exception);

        final onErrorInvocation = verify(listener.onError(captureAny));

        expect(onErrorInvocation.callCount, 1);
        expect(onErrorInvocation.captured, [exception]);
      });
    });

    group('#verifySMSCode', () {
      test(
        'calls FirebaseAuth#signInWithCredential if action is sign in',
        () {
          provider.verifySMSCode(
            action: AuthAction.signIn,
            code: '123456',
            verificationId: 'verificationId',
          );

          final invocation = verify(auth.signInWithCredential(captureAny));

          expect(invocation.callCount, 1);
          expect(invocation.captured.first, isA<PhoneAuthCredential>());

          final cred = invocation.captured.first as PhoneAuthCredential;

          expect(cred.smsCode, '123456');
          expect(cred.verificationId, 'verificationId');
        },
      );

      test('calls onBeforeSignIn if action is sign in', () {
        provider.verifySMSCode(
          action: AuthAction.signIn,
          code: '123456',
          verificationId: 'verificationId',
        );

        final invocation = verify(listener.onBeforeSignIn());
        expect(invocation.callCount, 1);
      });

      test('calls onSignedIn if sign in succeded', () async {
        final cred = MockUserCredential();
        when(auth.signInWithCredential(any)).thenAnswer((_) async => cred);

        provider.verifySMSCode(
          action: AuthAction.signIn,
          code: '123456',
          verificationId: 'verificationId',
        );

        await untilCalled(listener.onBeforeSignIn());

        final invocation = verify(listener.onSignedIn(captureAny));

        expect(invocation.callCount, 1);
        expect(invocation.captured, [cred]);
      });

      test('calls onError if sign in failed', () async {
        final exception = TestException();

        when(auth.signInWithCredential(any)).thenThrow(exception);

        provider.verifySMSCode(
          action: AuthAction.signIn,
          code: '123456',
          verificationId: 'verificationId',
        );

        await untilCalled(listener.onBeforeSignIn());

        final onErrorInvocation = verify(listener.onError(captureAny));

        expect(onErrorInvocation.callCount, 1);
        expect(onErrorInvocation.captured, [exception]);
      });

      test('calls linkWithCredential if action is link', () {
        final user = MockUser();
        auth.user = user;

        provider.verifySMSCode(
          action: AuthAction.link,
          code: '123456',
          verificationId: 'verificationId',
        );

        verify(user.linkWithCredential(any)).called(1);
      });

      test('calls onBeforeCredentialLinked if action is link', () {
        provider.verifySMSCode(
          action: AuthAction.link,
          code: '123456',
          verificationId: 'verificationId',
        );

        final invocation = verify(
          listener.onCredentialReceived(captureAny),
        );

        expect(invocation.callCount, 1);
        expect(invocation.captured.first, isA<PhoneAuthCredential>());

        final cred = invocation.captured.first as PhoneAuthCredential;

        expect(cred.smsCode, '123456');
        expect(cred.verificationId, 'verificationId');
      });

      test(
        'calls onCredentialLinked if credential linking succeded',
        () async {
          final user = MockUser();
          auth.user = user;

          provider.verifySMSCode(
            action: AuthAction.link,
            code: '123456',
            verificationId: 'verificationId',
          );

          await untilCalled(user.linkWithCredential(any));

          final invocation = verify(listener.onCredentialLinked(captureAny));

          expect(invocation.callCount, 1);
          expect(invocation.captured.first, isA<PhoneAuthCredential>());

          final cred = invocation.captured.first as PhoneAuthCredential;

          expect(cred.smsCode, '123456');
          expect(cred.verificationId, 'verificationId');
        },
      );
    });

    group('PhoneAuthController', () {
      group('#acceptPhoneNumber', () {
        test('calls PhoneAuthProvider#sendVerificationCode', () {
          final provider = MockProvider();
          final ctrl = PhoneAuthFlow(provider: provider, auth: MockAuth());

          ctrl.acceptPhoneNumber('+123456789');

          final invocation = verify(
            provider.sendVerificationCode(
              phoneNumber: captureAnyNamed('phoneNumber'),
              action: anyNamed('action'),
              forceResendingToken: anyNamed('forceResendingToken'),
              hint: anyNamed('hint'),
              multiFactorSession: anyNamed('multiFactorSession'),
            ),
          )..called(1);

          expect(invocation.callCount, 1);
          expect(invocation.captured, ['+123456789']);
        });
      });

      group('#verifySMSCode', () {
        test('calls PhoneAuthProvider#verifySMSCode', () {
          final provider = MockProvider();
          final ctrl = PhoneAuthFlow(provider: provider, auth: MockAuth());

          ctrl.verifySMSCode('123456', verificationId: 'verificationId');

          final invocation = verify(
            provider.verifySMSCode(
              action: anyNamed('action'),
              code: captureAnyNamed('code'),
              verificationId: captureAnyNamed('verificationId'),
            ),
          );

          expect(invocation.callCount, 1);
          expect(invocation.captured, ['123456', 'verificationId']);
        });
      });
    });
  });
}

class MockProvider extends Mock implements PhoneAuthProvider {
  @override
  void sendVerificationCode({
    String? phoneNumber,
    AuthAction? action,
    int? forceResendingToken,
    MultiFactorSession? multiFactorSession,
    PhoneMultiFactorInfo? hint,
  }) {
    super.noSuchMethod(
      Invocation.method(
        #sendVerificationCode,
        null,
        {
          #phoneNumber: phoneNumber,
          #action: action,
          #forceResendingToken: forceResendingToken,
          #multiFactorSession: multiFactorSession,
          #hint: hint,
        },
      ),
    );
  }

  @override
  void verifySMSCode({
    AuthAction? action,
    String? code,
    String? verificationId,
    ConfirmationResult? confirmationResult,
  }) {
    super.noSuchMethod(
      Invocation.method(
        #verifySMSCode,
        null,
        {
          #action: action,
          #code: code,
          #verificationId: verificationId,
          #confirmationResult: confirmationResult,
        },
      ),
    );
  }
}

class MockUserCredential extends Mock implements UserCredential {}

class MockPhoneCredential extends Mock implements PhoneAuthCredential {}

class MockListener extends Mock implements PhoneAuthListener {
  @override
  void onCodeSent(String? verificationId, [int? forceResendToken]) {
    super.noSuchMethod(
      Invocation.method(
        #onCodeSent,
        [
          verificationId,
          forceResendToken,
        ],
      ),
    );
  }

  @override
  void onSMSCodeRequested(String? phoneNumber) {
    super.noSuchMethod(
      Invocation.method(
        #onSMSCodeRequested,
        [phoneNumber],
      ),
    );
  }

  @override
  void onCredentialLinked(AuthCredential? credential) {
    super.noSuchMethod(
      Invocation.method(
        #onCredentialLinked,
        [credential],
      ),
    );
  }

  @override
  void onVerificationCompleted(PhoneAuthCredential? credential) {
    super.noSuchMethod(
      Invocation.method(
        #onVerificationCompleted,
        [credential],
      ),
    );
  }

  @override
  void onError(Object? error) {
    super.noSuchMethod(
      Invocation.method(
        #onError,
        [error],
      ),
    );
  }

  @override
  void onCredentialReceived(AuthCredential? credential) {
    super.noSuchMethod(
      Invocation.method(
        #onBeforeCredentialLinked,
        [credential],
      ),
    );
  }

  @override
  void onSignedIn(UserCredential? credential) {
    super.noSuchMethod(
      Invocation.method(
        #onSignedIn,
        [credential],
      ),
    );
  }
}
