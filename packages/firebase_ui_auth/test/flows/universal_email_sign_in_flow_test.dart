// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:mockito/mockito.dart';

import '../test_utils.dart';

void main() {
  late UniversalEmailSignInProvider provider;
  late MockAuth auth;
  late MockListener listener;

  setUp(() {
    auth = MockAuth();
    listener = MockListener();

    provider = UniversalEmailSignInProvider();
    provider.auth = auth;
    provider.authListener = listener;
  });

  group('UniversalEmailSignInProvider', () {
    test('has correct provider id', () {
      expect(provider.providerId, 'universal_email_sign_in');
    });

    group('#findProvidersForEmail', () {
      test('calls FirebaseAuth#fetchSignInMethodsForEmail', () {
        provider.findProvidersForEmail('test@test.com');
        final invocation = verify(auth.fetchSignInMethodsForEmail(captureAny));

        expect(invocation.callCount, 1);
        expect(invocation.captured, ['test@test.com']);
      });

      test(
        'calls onBeforeProvidersForEmailFetch',
        () {
          provider.findProvidersForEmail('test@test.com');
          verify(listener.onBeforeProvidersForEmailFetch()).called(1);
        },
      );

      test('calls onDifferentProvidersFound', () async {
        provider.findProvidersForEmail('test@test.com');
        await untilCalled(listener.onBeforeProvidersForEmailFetch());

        final invocation = verify(
          listener.onDifferentProvidersFound(
            captureAny,
            captureAny,
            captureAny,
          ),
        );

        invocation.called(1);

        expect(invocation.captured, [
          'test@test.com',
          ['phone'],
          null,
        ]);
      });

      test('calls onError if an error occured', () async {
        final exception = TestException();
        when(auth.fetchSignInMethodsForEmail(any)).thenThrow(exception);

        provider.findProvidersForEmail('test@test.com');
        await untilCalled(listener.onError(any));

        final invocation = verify(listener.onError(captureAny));

        expect(invocation.callCount, 1);
        expect(invocation.captured, [exception]);
      });
    });

    group('UniversalEmailSignInController', () {
      group('#findProvidersForEmail', () {
        test(
          'calls UniversalEmailSignInProvider#findProvidersForEmail',
          () async {
            final provider = MockProvider();

            UniversalEmailSignInController ctrl = UniversalEmailSignInFlow(
              provider: provider,
              auth: auth,
            );

            ctrl.findProvidersForEmail('test@test.com');
            final invocation = verify(
              provider.findProvidersForEmail(captureAny),
            );

            expect(invocation.callCount, 1);
            expect(invocation.captured, ['test@test.com']);
          },
        );
      });
    });
  });
}

class MockListener extends Mock implements UniversalEmailSignInListener {
  @override
  void onBeforeProvidersForEmailFetch() {
    super.noSuchMethod(
      Invocation.method(#onBeforeProvidersForEmailFetch, null),
    );
  }

  @override
  void onDifferentProvidersFound(
    String? email,
    List<String>? providers,
    AuthCredential? credential,
  ) {
    super.noSuchMethod(
      Invocation.method(
        #onDifferentProvidersFound,
        [email, providers, credential],
      ),
    );
  }

  @override
  void onError(Object? error) {
    super.noSuchMethod(
      Invocation.method(#onError, [error]),
    );
  }
}

class MockProvider extends Mock implements UniversalEmailSignInProvider {
  @override
  void findProvidersForEmail(
    String? email, [
    AuthCredential? credential,
  ]) {
    super.noSuchMethod(
      Invocation.method(
        #findProvidersForEmail,
        [email, credential],
      ),
    );
  }
}
