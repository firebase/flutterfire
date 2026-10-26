// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_platform_interface/src/method_channel/method_channel_firebase_auth.dart';
import 'package:firebase_auth_platform_interface/src/pigeon/messages.pigeon.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock.dart';

const _authChannel = 'test/firebase_auth/auth-state';
const _tokenChannel = 'test/firebase_auth/id-token';

void main() {
  setupFirebaseAuthMocks();

  late MethodChannelFirebaseAuth auth;
  late FirebaseApp app;
  final subscriptions = <StreamSubscription<UserPlatform?>>[];
  final user = InternalUserDetails(
    userInfo: InternalUserInfo(
      uid: 'test-user',
      isAnonymous: false,
      isEmailVerified: false,
    ),
    providerData: [],
  );
  final userEvent = <String, dynamic>{
    'user': [user.userInfo.encode(), []],
  };
  final hostResponses = <String, Object?>{
    'registerAuthStateListener': _authChannel,
    'registerIdTokenListener': _tokenChannel,
    'signInAnonymously': InternalUserCredential(user: user),
    'signOut': null,
  };
  BasicMessageChannel<Object?> hostChannel(String method) =>
      BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.firebase_auth_platform_interface.FirebaseAuthHostApi.$method',
        FirebaseAuthHostApi.pigeonChannelCodec,
      );

  setUpAll(() async {
    app = await Firebase.initializeApp();
  });

  setUp(() async {
    for (final entry in hostResponses.entries) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockDecodedMessageHandler<Object?>(
        hostChannel(entry.key),
        (_) async => <Object?>[entry.value],
      );
    }
    final listeners = <Future<void>>[];
    for (final channel in [_authChannel, _tokenChannel]) {
      final listening = Completer<void>();
      listeners.add(listening.future);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(channel), (call) async {
        if (call.method == 'listen') {
          listening.complete();
        }
        return null;
      });
    }
    auth = MethodChannelFirebaseAuth.instance.delegateFor(app: app)
        as MethodChannelFirebaseAuth;
    await Future.wait(listeners);
  });

  tearDown(() async {
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
    subscriptions.clear();
    await auth.dispose();
    for (final method in hostResponses.keys) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockDecodedMessageHandler<Object?>(hostChannel(method), null);
    }
    for (final channel in [_authChannel, _tokenChannel]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(channel), null);
    }
  });

  Future<List<UserPlatform?>> listen(Stream<UserPlatform?> stream) async {
    final events = <UserPlatform?>[];
    subscriptions.add(stream.listen(events.add));
    await pumpEventQueue();
    return events;
  }

  for (final streamName in [
    'authStateChanges',
    'idTokenChanges',
    'userChanges',
  ]) {
    group(streamName, () {
      Stream<UserPlatform?> stream() => switch (streamName) {
            'authStateChanges' => auth.authStateChanges(),
            'idTokenChanges' => auth.idTokenChanges(),
            _ => auth.userChanges(),
          };
      final channel =
          streamName == 'authStateChanges' ? _authChannel : _tokenChannel;

      test('does not repeat null when already signed out', () async {
        final events = await listen(stream());
        await injectEventChannelResponse(channel, {'user': null});
        await pumpEventQueue();
        expect(events, [null]);
      });

      test('does not repeat null after signing out before listening', () async {
        auth.setInitialValues(currentUser: user);
        await auth.signOut();
        final events = await listen(stream());
        await injectEventChannelResponse(channel, {'user': null});
        await pumpEventQueue();
        expect(events, [null]);
      });

      test('dedupes sign-out independently for late subscribers', () async {
        auth.setInitialValues(currentUser: user);
        final events = await listen(stream());
        await auth.signOut();
        final lateEvents = await listen(stream());
        await injectEventChannelResponse(channel, {'user': null});
        await pumpEventQueue();
        expect(events.map((event) => event?.uid), ['test-user', null]);
        expect(lateEvents, [null]);
      });

      test('emits null when a signed-in user signs out', () async {
        auth.setInitialValues(currentUser: user);
        final events = await listen(stream());
        await injectEventChannelResponse(channel, {'user': null});
        await pumpEventQueue();
        expect(events.map((event) => event?.uid), ['test-user', null]);
        expect(auth.currentUser, isNull);
      });

      test('emits null after signing in before any native events', () async {
        await auth.signInAnonymously();
        final events = await listen(stream());
        await injectEventChannelResponse(channel, {'user': null});
        await pumpEventQueue();
        expect(events.map((event) => event?.uid), ['test-user', null]);
        expect(auth.currentUser, isNull);
      });

      test('emits a user when signing in', () async {
        final events = await listen(stream());
        await injectEventChannelResponse(channel, userEvent);
        await pumpEventQueue();
        expect(events.map((event) => event?.uid), [null, 'test-user']);
        expect(auth.currentUser?.uid, 'test-user');
      });

      test('emits sign-out only once after signing in', () async {
        final events = await listen(stream());
        await injectEventChannelResponse(channel, userEvent);
        await injectEventChannelResponse(channel, {'user': null});
        await injectEventChannelResponse(channel, {'user': null});
        await pumpEventQueue();
        expect(events.map((event) => event?.uid), [null, 'test-user', null]);
      });

      test('keeps non-null callbacks for the same user', () async {
        auth.setInitialValues(currentUser: user);
        final events = await listen(stream());
        await injectEventChannelResponse(channel, userEvent);
        await pumpEventQueue();
        expect(events.map((event) => event?.uid), ['test-user', 'test-user']);
      });
    });
  }

  for (final channels in [
    [_authChannel, _tokenChannel],
    [_tokenChannel, _authChannel],
  ]) {
    test('all streams emit sign-out with ${channels.first} arriving first',
        () async {
      auth.setInitialValues(currentUser: user);
      final events = await Future.wait([
        listen(auth.authStateChanges()),
        listen(auth.idTokenChanges()),
        listen(auth.userChanges()),
      ]);
      for (final channel in channels) {
        await injectEventChannelResponse(channel, {'user': null});
      }
      await pumpEventQueue();
      for (final streamEvents in events) {
        expect(streamEvents.map((event) => event?.uid), ['test-user', null]);
      }
    });
  }

  test('all streams emit sign-out after the signOut method returns', () async {
    auth.setInitialValues(currentUser: user);
    final events = await Future.wait([
      listen(auth.authStateChanges()),
      listen(auth.idTokenChanges()),
      listen(auth.userChanges()),
    ]);
    await auth.signOut();
    expect(auth.currentUser, isNull);
    await injectEventChannelResponse(_authChannel, {'user': null});
    await injectEventChannelResponse(_tokenChannel, {'user': null});
    await pumpEventQueue();
    for (final streamEvents in events) {
      expect(streamEvents.map((event) => event?.uid), ['test-user', null]);
    }
  });
}
