// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Mocks generated by Mockito 5.4.4 from annotations
// in firebase_analytics_web/test/firebase_analytics_web_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;

import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart'
    as _i3;
import 'package:firebase_analytics_web/firebase_analytics_web.dart' as _i4;
import 'package:firebase_core/firebase_core.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeFirebaseApp_0 extends _i1.SmartFake implements _i2.FirebaseApp {
  _FakeFirebaseApp_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeFirebaseAnalyticsPlatform_1 extends _i1.SmartFake
    implements _i3.FirebaseAnalyticsPlatform {
  _FakeFirebaseAnalyticsPlatform_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [FirebaseAnalyticsWeb].
///
/// See the documentation for Mockito's code generation for more information.
class MockFirebaseAnalyticsWeb extends _i1.Mock
    implements _i4.FirebaseAnalyticsWeb {
  @override
  set appInstance(_i2.FirebaseApp? _appInstance) => super.noSuchMethod(
        Invocation.setter(
          #appInstance,
          _appInstance,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i2.FirebaseApp get app => (super.noSuchMethod(
        Invocation.getter(#app),
        returnValue: _FakeFirebaseApp_0(
          this,
          Invocation.getter(#app),
        ),
        returnValueForMissingStub: _FakeFirebaseApp_0(
          this,
          Invocation.getter(#app),
        ),
      ) as _i2.FirebaseApp);

  @override
  _i3.FirebaseAnalyticsPlatform delegateFor({
    _i2.FirebaseApp? app,
    Map<String, dynamic>? webOptions,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #delegateFor,
          [],
          {
            #app: app,
            #webOptions: webOptions,
          },
        ),
        returnValue: _FakeFirebaseAnalyticsPlatform_1(
          this,
          Invocation.method(
            #delegateFor,
            [],
            {
              #app: app,
              #webOptions: webOptions,
            },
          ),
        ),
        returnValueForMissingStub: _FakeFirebaseAnalyticsPlatform_1(
          this,
          Invocation.method(
            #delegateFor,
            [],
            {
              #app: app,
              #webOptions: webOptions,
            },
          ),
        ),
      ) as _i3.FirebaseAnalyticsPlatform);

  @override
  _i5.Future<bool> isSupported() => (super.noSuchMethod(
        Invocation.method(
          #isSupported,
          [],
        ),
        returnValue: _i5.Future<bool>.value(false),
        returnValueForMissingStub: _i5.Future<bool>.value(false),
      ) as _i5.Future<bool>);

  @override
  _i5.Future<int?> getSessionId() => (super.noSuchMethod(
        Invocation.method(
          #getSessionId,
          [],
        ),
        returnValue: _i5.Future<int?>.value(),
        returnValueForMissingStub: _i5.Future<int?>.value(),
      ) as _i5.Future<int?>);

  @override
  _i5.Future<void> logEvent({
    required String? name,
    Map<String, Object?>? parameters,
    _i3.AnalyticsCallOptions? callOptions,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #logEvent,
          [],
          {
            #name: name,
            #parameters: parameters,
            #callOptions: callOptions,
          },
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> setConsent({
    bool? adStorageConsentGranted,
    bool? analyticsStorageConsentGranted,
    bool? adPersonalizationSignalsConsentGranted,
    bool? adUserDataConsentGranted,
    bool? functionalityStorageConsentGranted,
    bool? personalizationStorageConsentGranted,
    bool? securityStorageConsentGranted,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #setConsent,
          [],
          {
            #adStorageConsentGranted: adStorageConsentGranted,
            #analyticsStorageConsentGranted: analyticsStorageConsentGranted,
            #adPersonalizationSignalsConsentGranted:
                adPersonalizationSignalsConsentGranted,
            #adUserDataConsentGranted: adUserDataConsentGranted,
            #functionalityStorageConsentGranted:
                functionalityStorageConsentGranted,
            #personalizationStorageConsentGranted:
                personalizationStorageConsentGranted,
            #securityStorageConsentGranted: securityStorageConsentGranted,
          },
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> setAnalyticsCollectionEnabled(bool? enabled) =>
      (super.noSuchMethod(
        Invocation.method(
          #setAnalyticsCollectionEnabled,
          [enabled],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> setUserId({
    String? id,
    _i3.AnalyticsCallOptions? callOptions,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #setUserId,
          [],
          {
            #id: id,
            #callOptions: callOptions,
          },
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> resetAnalyticsData() => (super.noSuchMethod(
        Invocation.method(
          #resetAnalyticsData,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> setUserProperty({
    required String? name,
    required String? value,
    _i3.AnalyticsCallOptions? callOptions,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #setUserProperty,
          [],
          {
            #name: name,
            #value: value,
            #callOptions: callOptions,
          },
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> setSessionTimeoutDuration(Duration? timeout) =>
      (super.noSuchMethod(
        Invocation.method(
          #setSessionTimeoutDuration,
          [timeout],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> setDefaultEventParameters(
          Map<String, Object?>? defaultParameters) =>
      (super.noSuchMethod(
        Invocation.method(
          #setDefaultEventParameters,
          [defaultParameters],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<String?> getAppInstanceId() => (super.noSuchMethod(
        Invocation.method(
          #getAppInstanceId,
          [],
        ),
        returnValue: _i5.Future<String?>.value(),
        returnValueForMissingStub: _i5.Future<String?>.value(),
      ) as _i5.Future<String?>);

  @override
  _i5.Future<void> initiateOnDeviceConversionMeasurement({
    String? emailAddress,
    String? phoneNumber,
    String? hashedEmailAddress,
    String? hashedPhoneNumber,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #initiateOnDeviceConversionMeasurement,
          [],
          {
            #emailAddress: emailAddress,
            #phoneNumber: phoneNumber,
            #hashedEmailAddress: hashedEmailAddress,
            #hashedPhoneNumber: hashedPhoneNumber,
          },
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}
