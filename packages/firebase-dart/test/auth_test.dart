@TestOn('browser')

import 'dart:async';
import 'dart:convert';
import 'dart:core' hide print;
import 'dart:core' as core show print;
import 'dart:html';

import 'package:firebase/firebase.dart';
import 'package:firebase/src/assets/assets.dart';
import 'package:test/test.dart';
import 'test_util.dart';

/// A nice util to include timing with print calls
void print(obj) => core.print(
    [(window.performance.now() * 100).toInt() / (100 * 1000), obj].join('\t'));

/// Wait for 500ms
Future _wait() async {
  //print("waiting...");
  await new Future.delayed(const Duration(milliseconds: 500));
  //print("waited...");
}

void main() {
  App app;

  setUpAll(() async {
    await config();
  });

  setUp(() async {
    app = initializeApp(
        apiKey: apiKey,
        authDomain: authDomain,
        databaseURL: databaseUrl,
        storageBucket: storageBucket);
  });

  tearDown(() async {
    if (app != null) {
      await app.delete();
      app = null;
    }
  });

  group('verifiers', () {
    DivElement el;

    group('Recaptcha', () {
      setUp(() {
        el = document.createElement("div")..id = "test-recaptcha";
        document.body.append(el);
      });

      tearDown(() {
        el.remove();
      });

      test('type', () {
        var verifier = new RecaptchaVerifier("test-recaptcha");
        expect(verifier.type, "recaptcha");
      });

      test('render', () async {
        var verifier = new RecaptchaVerifier("test-recaptcha");
        await verifier.render();

        var iframe = document.querySelector("#test-recaptcha iframe");
        expect(iframe, isNotNull);
        expect(iframe.getAttribute("src"), contains("recaptcha"));
      });

      test('clear', () async {
        var verifier = new RecaptchaVerifier("test-recaptcha");
        await verifier.render();

        var iframe = document.querySelector("#test-recaptcha iframe");
        expect(iframe, isNotNull);

        verifier.clear();

        iframe = document.querySelector("#test-recaptcha iframe");
        expect(iframe, isNull);
      });
    });
  });

  group('providers', () {
    group('Email', () {
      test('PROVIDER_ID', () {
        expect(EmailAuthProvider.PROVIDER_ID, 'password');
      });
      test('instance', () {
        var provider = new EmailAuthProvider();
        expect(provider.providerId, EmailAuthProvider.PROVIDER_ID);
      });
      test('credential', () {
        var cred = EmailAuthProvider.credential('un', 'pw');
        expect(cred.providerId, equals(EmailAuthProvider.PROVIDER_ID));
      });
    });

    group('Facebook', () {
      test('PROVIDER_ID', () {
        expect(FacebookAuthProvider.PROVIDER_ID, 'facebook.com');
      });
      test('instance', () {
        var provider = new FacebookAuthProvider();
        expect(provider.providerId, FacebookAuthProvider.PROVIDER_ID);
      });
      test('credential', () {
        var cred = FacebookAuthProvider.credential('token');
        expect(cred.providerId, equals(FacebookAuthProvider.PROVIDER_ID));
      });
      test('scope', () {
        var provider = new FacebookAuthProvider();
        var providerWithScope = provider.addScope('user_birthday');
        expect(provider.providerId, equals(providerWithScope.providerId));
      });
      test('custom parameters', () {
        var provider = new FacebookAuthProvider();
        var providerWithParameters =
            provider.setCustomParameters({'display': 'popup'});
        expect(provider.providerId, equals(providerWithParameters.providerId));
      });
    });

    group('GitHub', () {
      test('PROVIDER_ID', () {
        expect(GithubAuthProvider.PROVIDER_ID, 'github.com');
      });
      test('instance', () {
        var provider = new GithubAuthProvider();
        expect(provider.providerId, GithubAuthProvider.PROVIDER_ID);
      });
      test('credential', () {
        var cred = GithubAuthProvider.credential('token');
        expect(cred.providerId, equals(GithubAuthProvider.PROVIDER_ID));
      });
      test('scope', () {
        var provider = new GithubAuthProvider();
        var providerWithScope = provider.addScope('repo');
        expect(provider.providerId, equals(providerWithScope.providerId));
      });
      test('custom parameters', () {
        var provider = new GithubAuthProvider();
        var providerWithParameters =
            provider.setCustomParameters({'allow_signup': 'false'});
        expect(provider.providerId, equals(providerWithParameters.providerId));
      });
    });

    group('Google', () {
      test('PROVIDER_ID', () {
        expect(GoogleAuthProvider.PROVIDER_ID, 'google.com');
      });
      test('instance', () {
        var provider = new GoogleAuthProvider();
        expect(provider.providerId, GoogleAuthProvider.PROVIDER_ID);
      });
      test('credential', () {
        var cred = GoogleAuthProvider.credential('idToken', 'accessToken');
        expect(cred.providerId, equals(GoogleAuthProvider.PROVIDER_ID));
      });
      test('scope', () {
        var provider = new GoogleAuthProvider();
        var providerWithScope =
            provider.addScope('https://www.googleapis.com/auth/plus.login');
        expect(provider.providerId, equals(providerWithScope.providerId));
      });
      test('custom parameters', () {
        var provider = new GoogleAuthProvider();
        var providerWithParameters = provider
            .setCustomParameters({'login_hint': 'some_email@example.com'});
        expect(provider.providerId, equals(providerWithParameters.providerId));
      });
    });

    group('Twitter', () {
      test('PROVIDER_ID', () {
        expect(TwitterAuthProvider.PROVIDER_ID, 'twitter.com');
      });
      test('instance', () {
        var provider = new TwitterAuthProvider();
        expect(provider.providerId, TwitterAuthProvider.PROVIDER_ID);
      });
      test('credential', () {
        var cred = TwitterAuthProvider.credential('token', 'secret');
        expect(cred.providerId, equals(TwitterAuthProvider.PROVIDER_ID));
      });
      test('custom parameters', () {
        var provider = new TwitterAuthProvider();
        var providerWithParameters =
            provider.setCustomParameters({'lang': 'es'});
        expect(provider.providerId, equals(providerWithParameters.providerId));
      });
    });

    group('Phone', () {
      test('PROVIDER_ID', () {
        expect(PhoneAuthProvider.PROVIDER_ID, 'phone');
      });
      test('instance', () {
        var provider = new PhoneAuthProvider();
        expect(provider.providerId, PhoneAuthProvider.PROVIDER_ID);
      });
      test('credential', () {
        var cred = PhoneAuthProvider.credential('id', 'code');
        expect(cred.providerId, equals(PhoneAuthProvider.PROVIDER_ID));
      });
    });
  });

  group('anonymous user', () {
    Auth authValue;
    User user;
    setUp(() async {
      authValue = auth();
      expect(authValue.currentUser, isNull);

      try {
        user = await authValue.signInAnonymously();
      } on FirebaseError catch (e) {
        printException(e);
        rethrow;
      }
    });

    tearDown(() async {
      if (user != null) {
        await user.delete();
        user = null;
      }
    });

    test('properties', () {
      expect(user.isAnonymous, isTrue);
      expect(user.emailVerified, isFalse);
      expect(user.providerData, isEmpty);
      expect(user.providerId, 'firebase');
      expect(user.metadata, isNotNull);
      expect(user.metadata.lastSignInTime, isNotNull);
      expect(user.metadata.creationTime, isNotNull);
    });

    test('delete', () async {
      await user.delete();
      expect(authValue.currentUser, isNull);

      try {
        await user.delete();
        fail('user.delete should throw');
      } on FirebaseError catch (e) {
        expect(e.code, 'auth/app-deleted');
      } catch (e) {
        fail('Should have been a FirebaseError');
      }
      user = null;
    });
  });

  group('user', () {
    Auth authValue;
    User user;
    String userEmail;
    User lastAuthEventUser;
    User lastIdTokenChangedUser;

    StreamSubscription authStateChangeSubscription;
    StreamSubscription idTokenChangedSubscription;

    setUp(() {
      authValue = auth();
      expect(authValue.currentUser, isNull);

      expect(userEmail, isNull);
      userEmail = getTestEmail();

      expect(lastAuthEventUser, isNull);
      expect(authStateChangeSubscription, isNull);

      expect(lastIdTokenChangedUser, isNull);
      expect(idTokenChangedSubscription, isNull);

      authStateChangeSubscription =
          authValue.onAuthStateChanged.listen((event) {
        lastAuthEventUser = event;
        //print('authstate - $event');
      }, onError: (e, stack) {
        print("AuthStateError! $e $stack");
      }, onDone: () {
        //print("done!");
      });

      idTokenChangedSubscription = authValue.onIdTokenChanged.listen((event) {
        lastIdTokenChangedUser = event;
      }, onError: (e, stack) {
        print("IdToken error! $e $stack");
      }, onDone: () {
        //print("done!");
      });
    });

    tearDown(() async {
      userEmail = null;
      if (user != null) {
        await user.delete();
        user = null;
      }

      if (authStateChangeSubscription != null) {
        await authStateChangeSubscription.cancel();
        authStateChangeSubscription = null;
        lastAuthEventUser = null;
      }

      if (idTokenChangedSubscription != null) {
        await idTokenChangedSubscription.cancel();
        idTokenChangedSubscription = null;
        lastIdTokenChangedUser = null;
      }
    });

    test('getIdToken', () async {
      try {
        user = await authValue.createUserWithEmailAndPassword(
            userEmail, "janicka");

        var token = await user.getIdToken();

        // The following is a basic verification of a JWT token
        // See https://en.wikipedia.org/wiki/JSON_Web_Token
        var split = token.split('.').map((t) {
          // If `t.length` is not a multiple of 4, pad it to the right w/ `=`.
          var originalLength = t.length;
          var remainder = (originalLength / 4).ceil() * 4 - originalLength;
          t = "$t${'='* remainder}";
          return BASE64URL.decode(t);
        }).toList();

        expect(split, hasLength(3));

        var header = JSON.decode(UTF8.decode(split.first));
        expect(header, isMap);
        expect(header, containsPair('alg', isNotEmpty));

        var payload = JSON.decode(UTF8.decode(split[1]));
        expect(payload, isMap);
        expect(payload, containsPair('email', userEmail));
      } on FirebaseError catch (e) {
        printException(e);
        rethrow;
      }
    });

    test('create user with email and password', () async {
      try {
        user = await authValue.createUserWithEmailAndPassword(
            userEmail, "janicka");
        expect(user, isNotNull);
        expect(user.email, userEmail);
        expect(user.phoneNumber, isNull);
      } on FirebaseError catch (e) {
        printException(e);
        rethrow;
      }
    });

    test('createUserAndRetrieveDataWithEmailAndPassword', () async {
      try {
        var credential =
            await authValue.createUserAndRetrieveDataWithEmailAndPassword(
                userEmail, "janicka");
        user = credential.user;
        expect(user, isNotNull);
        expect(user.email, userEmail);
        expect(user.phoneNumber, isNull);
        expect(credential.additionalUserInfo.isNewUser, isTrue);
      } on FirebaseError catch (e) {
        printException(e);
        rethrow;
      }
    });

    test('signInAnonymouslyAndRetrieveData', () async {
      try {
        var credential = await authValue.signInAnonymouslyAndRetrieveData();
        user = credential.user;

        expect(user.isAnonymous, isTrue);
      } on FirebaseError catch (e) {
        printException(e);
        rethrow;
      }
    });

    test('link anonymous user with credential', () async {
      try {
        user = await authValue.signInAnonymously();
        expect(user.isAnonymous, isTrue);

        var credential = EmailAuthProvider.credential(userEmail, "janicka");
        user = await user.linkWithCredential(credential);
        expect(user.isAnonymous, isFalse);
        expect(user.email, userEmail);
      } on FirebaseError catch (e) {
        printException(e);
        rethrow;
      }
    });

    test('linkAndRetrieveDataWithCredential anonymous user', () async {
      try {
        user = await authValue.signInAnonymously();
        expect(user.isAnonymous, isTrue);

        var credential = EmailAuthProvider.credential(userEmail, "janicka");
        var userCred = await user.linkAndRetrieveDataWithCredential(credential);

        expect(userCred.operationType, 'link');
        expect(userCred.user.uid, user.uid);
        expect(userCred.additionalUserInfo, isNotNull);
        expect(userCred.additionalUserInfo.isNewUser, isFalse);
      } on FirebaseError catch (e) {
        printException(e);
        rethrow;
      }
    });

    test('reauthenticate with credential', () async {
      try {
        user = await authValue.createUserWithEmailAndPassword(
            userEmail, "janicka");

        var credential = EmailAuthProvider.credential(userEmail, "janicka");
        await user.reauthenticateWithCredential(credential);

        expect(authValue.currentUser, isNotNull);
        expect(authValue.currentUser.email, userEmail);
      } on FirebaseError catch (e) {
        printException(e);
        rethrow;
      }
    });

    test('reauthenticateAndRetrieveDataWithCredential', () async {
      try {
        user = await authValue.createUserWithEmailAndPassword(
            userEmail, "janicka");

        var credential = EmailAuthProvider.credential(userEmail, "janicka");
        var userCred =
            await user.reauthenticateAndRetrieveDataWithCredential(credential);

        expect(userCred.operationType, 'reauthenticate');
        expect(userCred.user.uid, user.uid);

        expect(lastAuthEventUser, isNotNull);
        expect(lastAuthEventUser.email, userEmail);
        expect(lastIdTokenChangedUser.email, userEmail);

        expect(authValue.currentUser, isNotNull);
        expect(authValue.currentUser.email, userEmail);
      } on FirebaseError catch (e) {
        printException(e);
        rethrow;
      }
    });

    test('reauthenticate with bad credential fails', () async {
      user =
          await authValue.createUserWithEmailAndPassword(userEmail, "janicka");
      var credential = EmailAuthProvider.credential(userEmail, "something");

      expect(
          user.reauthenticateWithCredential(credential),
          throwsToString(contains(
              'The password is invalid or the user does not have a password')));
    });

    test("signInAndRetrieveDataWithCredential", () async {
      user =
          await authValue.createUserWithEmailAndPassword(userEmail, "janicka");

      // Firefox takes a second to get the event values that are checked below
      await _wait();

      // at this point, we should have the same refresh tokens for "everything"
      expect(lastAuthEventUser, isNotNull);
      expect(lastIdTokenChangedUser, isNotNull);

      lastAuthEventUser = null;
      lastIdTokenChangedUser = null;

      var credential = EmailAuthProvider.credential(userEmail, "janicka");

      var userCred =
          await authValue.signInAndRetrieveDataWithCredential(credential);

      // Firefox takes a second to get the event values that are checked below
      await _wait();

      expect(userCred.operationType, 'signIn');

      // at this point, the `lastIdTokenChangedUser` should be different
      // it's newer!
      expect(lastAuthEventUser, isNull,
          reason: 'Not updated with signInAndRetrieveDataWithCredential');
      expect(lastIdTokenChangedUser, isNotNull,
          reason: 'Is updated with signInAndRetrieveDataWithCredential');
    });

    test("signInAndRetrieveDataWithEmailAndPassword", () async {
      var credential = await authValue
          .createUserAndRetrieveDataWithEmailAndPassword(userEmail, "janicka");

      expect(credential.user.email, userEmail);
      expect(credential.additionalUserInfo.isNewUser, isTrue);

      await authValue.signOut();

      await _wait();

      var credential2 = await authValue
          .signInAndRetrieveDataWithEmailAndPassword(userEmail, "janicka");

      expect(credential.user.email, credential2.user.email);
      expect(credential2.additionalUserInfo.isNewUser, isFalse);
    });

    test('language', () {
      expect(authValue.languageCode, isNull);

      authValue.languageCode = 'cs';
      expect(authValue.languageCode, 'cs');

      authValue.useDeviceLanguage();
      // the default device's lang is used and not null
      expect(authValue.languageCode, isNotNull);
    });
  });

  group('registered user', () {
    Auth authValue;
    User user;

    setUp(() async {
      authValue = auth();

      try {
        user = await authValue.createUserWithEmailAndPassword(
            getTestEmail(), "hesloheslo");
        expect(authValue.currentUser, isNotNull);
      } on FirebaseError catch (e) {
        printException(e);
        rethrow;
      }
    });

    tearDown(() async {
      if (user != null) {
        await user.delete();
        user = null;
      }
    });

    test('update profile', () async {
      try {
        expect(user, isNotNull);
        expect(user.displayName, isNull);

        var profile = new UserProfile(displayName: "Other User");
        await user.updateProfile(profile);
        expect(user.displayName, "Other User");
      } on FirebaseError catch (e) {
        printException(e);
        rethrow;
      }
    });

    test('toJson', () async {
      try {
        expect(user, isNotNull);

        var profile = new UserProfile(
            displayName: "Other User", photoURL: "http://google.com");
        await user.updateProfile(profile);

        var userMap = user.toJson();
        expect(userMap, isNotNull);
        expect(userMap, isNotEmpty);
        expect(userMap["displayName"], "Other User");
        expect(userMap["photoURL"], "http://google.com");

        await authValue.signOut();
        await authValue.signInAnonymously();
        user = authValue.currentUser;

        userMap = user.toJson();
        expect(userMap, isNotNull);
        expect(userMap, isNotEmpty);
        expect(userMap["displayName"], isNot("Other User"));
        expect(userMap["photoURL"], isNot("http://google.com"));
        expect(userMap["phoneNumber"], isNull);
      } on FirebaseError catch (e) {
        printException(e);
        rethrow;
      }
    });
  });
}
