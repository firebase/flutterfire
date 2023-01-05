// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';

class TestMaterialApp extends StatelessWidget {
  final Widget child;

  const TestMaterialApp({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }
}

class MockCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {
  @override
  Future<UserCredential> linkWithCredential(AuthCredential? credential) async {
    return super.noSuchMethod(
      Invocation.method(
        #linkWithCredential,
        [credential],
      ),
      returnValue: MockCredential(),
      returnValueForMissingStub: MockCredential(),
    );
  }
}

class MockLinksStream extends Mock implements Stream<PendingDynamicLinkData> {
  @override
  Future<PendingDynamicLinkData> get first async {
    return super.noSuchMethod(
      Invocation.getter(#first),
      returnValue: PendingDynamicLinkData(
        link: Uri.parse('https://test.com'),
      ),
      returnValueForMissingStub: PendingDynamicLinkData(
        link: Uri.parse('https://test.com'),
      ),
    );
  }
}

class MockDynamicLinks extends Mock implements FirebaseDynamicLinks {
  static final _linkStream = MockLinksStream();

  @override
  Stream<PendingDynamicLinkData> get onLink => _linkStream;
}

class MockAuth extends Mock implements FirebaseAuth {
  MockUser? user;

  @override
  User? get currentUser => user;

  @override
  Future<UserCredential> signInWithCredential(
    AuthCredential? credential,
  ) async {
    return super.noSuchMethod(
      Invocation.method(
        #signInWithCredential,
        [credential],
      ),
      returnValue: MockCredential(),
      returnValueForMissingStub: MockCredential(),
    );
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    String? email,
    String? password,
  }) async {
    return super.noSuchMethod(
      Invocation.method(#createUserWithEmailAndPassword, null, {
        #email: email,
        #password: password,
      }),
      returnValue: MockCredential(),
      returnValueForMissingStub: MockCredential(),
    );
  }

  @override
  Future<void> sendSignInLinkToEmail({
    required String? email,
    required ActionCodeSettings? actionCodeSettings,
  }) async {
    return super.noSuchMethod(
      Invocation.method(
        #sendSignInLinkToEmail,
        null,
        {
          #email: email,
          #actionCodeSettings: actionCodeSettings,
        },
      ),
      returnValueForMissingStub: null,
    );
  }

  @override
  bool isSignInWithEmailLink(String? emailLink) {
    return super.noSuchMethod(
      Invocation.method(
        #isSignInWithEmailLink,
        [emailLink],
      ),
      returnValue: true,
      returnValueForMissingStub: true,
    );
  }

  @override
  Future<UserCredential> signInWithEmailLink({
    required String? email,
    required String? emailLink,
  }) async {
    return super.noSuchMethod(
      Invocation.method(
        #signInWithEmailLink,
        null,
        {
          #email: email,
          #emailLink: emailLink,
        },
      ),
      returnValue: MockCredential(),
      returnValueForMissingStub: MockCredential(),
    );
  }

  @override
  Future<List<String>> fetchSignInMethodsForEmail(String? email) async {
    return super.noSuchMethod(
      Invocation.method(
        #fetchSignInMethodsForEmail,
        [email],
      ),
      returnValue: <String>['phone'],
      returnValueForMissingStub: <String>['phone'],
    );
  }

  @override
  Future<void> verifyPhoneNumber({
    String? phoneNumber,
    PhoneMultiFactorInfo? multiFactorInfo,
    PhoneVerificationCompleted? verificationCompleted,
    PhoneVerificationFailed? verificationFailed,
    PhoneCodeSent? codeSent,
    PhoneCodeAutoRetrievalTimeout? codeAutoRetrievalTimeout,
    String? autoRetrievedSmsCodeForTesting,
    Duration timeout = const Duration(seconds: 30),
    int? forceResendingToken,
    MultiFactorSession? multiFactorSession,
  }) async {
    super.noSuchMethod(
      Invocation.method(
        #verifyPhoneNumber,
        null,
        {
          #phoneNumber: phoneNumber,
          #verificationCompleted: verificationCompleted,
          #verificationFailed: verificationFailed,
          #codeSent: codeSent,
          #codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
          #autoRetrievedSmsCodeForTesting: autoRetrievedSmsCodeForTesting,
          #timeout: timeout,
          #forceResendingToken: forceResendingToken,
        },
      ),
    );
  }
}

class TestException implements Exception {}
