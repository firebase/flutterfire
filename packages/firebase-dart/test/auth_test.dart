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
        expect(cred.provider, equals(EmailAuthProvider.PROVIDER_ID));
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
        expect(cred.provider, equals(FacebookAuthProvider.PROVIDER_ID));
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
        expect(cred.provider, equals(GithubAuthProvider.PROVIDER_ID));
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
        expect(cred.provider, equals(GoogleAuthProvider.PROVIDER_ID));
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
        expect(cred.provider, equals(TwitterAuthProvider.PROVIDER_ID));
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

    setUp(() {
      authValue = auth();
      expect(authValue.currentUser, isNull);
    });

    tearDown(() async {
      if (user != null) {
        await user.delete();
        user = null;
      }
    });

    test('create user with email and password', () async {
      try {
        user = await authValue.createUserWithEmailAndPassword(
            "some_user@example.com", "janicka");
        expect(user, isNotNull);
        expect(user.email, "some_user@example.com");
      } on FirebaseError catch (e) {
        printException(e);
        rethrow;
      }
    });
  });

  group('registered user', () {
    Auth authValue;
    User user;

    setUp(() async {
      authValue = auth();

      try {
        user = await authValue.createUserWithEmailAndPassword(
            "other_user@example.com", "hesloheslo");
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
