@TestOn('browser')
import 'package:firebase/firebase.dart';
import 'package:firebase/src/assets/assets.dart';
import 'package:test/test.dart';
import 'test_util.dart';

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

    setUp(() {
      authValue = auth();
      expect(authValue.currentUser, isNull);

      expect(userEmail, isNull);
      userEmail = getTestEmail();
    });

    tearDown(() async {
      userEmail = null;
      if (user != null) {
        await user.delete();
        user = null;
      }
    });

    test('create user with email and password', () async {
      try {
        user = await authValue.createUserWithEmailAndPassword(
            userEmail, "janicka");
        expect(user, isNotNull);
        expect(user.email, userEmail);
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

    test('reauthenticate with bad credential fails', () async {
      user =
          await authValue.createUserWithEmailAndPassword(userEmail, "janicka");
      var credential = EmailAuthProvider.credential(userEmail, "something");

      expect(user.reauthenticateWithCredential(credential), throws);
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
  });
}
