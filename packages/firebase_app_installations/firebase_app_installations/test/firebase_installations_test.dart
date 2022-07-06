// ignore_for_file: require_trailing_commas
// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_app_installations_platform_interface/firebase_app_installations_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

typedef Callback = Function(MethodCall call);
final mockInstallations = MockFirebaseInstallations();

void main() {
  setupFirebaseInstallationsMocks();

  late FirebaseInstallations installations;
  FirebaseAppInstallationsPlatform.instance = mockInstallations;
  group('$FirebaseInstallations', () {
    setUpAll(() async {
      await Firebase.initializeApp();
      installations = FirebaseInstallations.instance;
      when(mockInstallations.delegateFor(
        app: anyNamed('app'),
      )).thenAnswer((_) => mockInstallations);
      when(mockInstallations.getId()).thenAnswer(
        (_) => Future.value('some-id'),
      );
    });

    test('getId', () async {
      await installations.getId();
      verify(mockInstallations.getId());
    });
    test('getAuthToken', () async {
      await installations.getToken();
      verify(mockInstallations.getToken());
    });
    test('delete', () async {
      await installations.delete();
      verify(mockInstallations.delete());
    });
  });
}

void setupFirebaseInstallationsMocks([Callback? customHandlers]) {
  TestWidgetsFlutterBinding.ensureInitialized();

  setupFirebaseCoreMocks();
}

class MockFirebaseInstallations extends Mock
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin
    implements
        TestFirebaseAppInstallationsPlatform {
  @override
  TestFirebaseAppInstallationsPlatform delegateFor({FirebaseApp? app}) {
    return super.noSuchMethod(
      Invocation.method(#delegateFor, [], {#app: app}),
      returnValue: TestFirebaseAppInstallationsPlatform(app),
      returnValueForMissingStub: TestFirebaseAppInstallationsPlatform(app),
    );
  }

  @override
  Future<String> getId() {
    return super.noSuchMethod(
      Invocation.method(#getId, []),
      returnValue: Future<String>.value(''),
      returnValueForMissingStub: Future<String>.value(''),
    );
  }

  @override
  // ignore: type_annotate_public_apis
  Future<String> getToken([forceRefresh = false]) {
    return super.noSuchMethod(
      Invocation.method(#getToken, [forceRefresh]),
      returnValue: Future<String>.value(''),
      returnValueForMissingStub: Future<String>.value(''),
    );
  }

  @override
  Future<void> delete() {
    return super.noSuchMethod(
      Invocation.method(#getId, []),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    );
  }
}

class TestFirebaseAppInstallationsPlatform
    extends FirebaseAppInstallationsPlatform {
  TestFirebaseAppInstallationsPlatform(FirebaseApp? app) : super(app);

  @override
  TestFirebaseAppInstallationsPlatform delegateFor({FirebaseApp? app}) {
    return this;
  }
}
