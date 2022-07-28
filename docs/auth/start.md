Project: /docs/_project.yaml
Book: /docs/_book.yaml

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Get Started with Firebase Authentication on Flutter

## Connect your app to Firebase

[Install and initialize the Firebase SDKs for Flutter](/docs/flutter/setup) if you haven't already done
so.

## Add Firebase Authentication to your app

1.  From the root of your Flutter project, run the following command to install
    the plugin:

    ```bash
    flutter pub add firebase_auth
    ```

1.  Once complete, rebuild your Flutter application:

    ```bash
    flutter run
    ```

1.  Import the plugin in your Dart code:

    ```dart
    import 'package:firebase_auth/firebase_auth.dart';
    ```

To use an authentication provider, you need to enable it in the [Firebase console](https://console.firebase.google.com/).
Go to the Sign-in Method page in the Firebase Authentication section to enable
Email/Password sign-in and any other identity providers you want for your app.

## (Optional) Prototype and test with Firebase Local Emulator Suite

Before talking about how your app authenticates users, let's introduce a set of
tools you can use to prototype and test Authentication functionality:
Firebase Local Emulator Suite. If you're deciding among authentication techniques
and providers, trying out different data models with public and private data
using Authentication and Firebase Security Rules, or prototyping sign-in UI designs, being able to
work locally without deploying live services can be a great idea.

An Authentication emulator is part of the Local Emulator Suite, which
enables your app to interact with emulated database content and config, as
well as optionally your emulated project resources (functions, other databases,
and security rules).

Using the Authentication emulator involves just a few steps:

1.  Adding a line of code to your app's test config to connect to the emulator.

1.  From the root of your local project directory, running `firebase emulators:start`.

1.  Using the Local Emulator Suite UI for interactive prototyping, or the
    Authentication emulator REST API for non-interactive testing.

1.  Call `useAuthEmulator()` to specify the emulator address and port:

    ```dart
    Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    // Ideal time to initialize
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    //...
    }
    ```

A detailed guide is available at [Connect your app to the Authentication emulator](/docs/emulator-suite/connect_auth).
For more information, see the [Local Emulator Suite introduction](/docs/emulator-suite/).

Now let's continue with how to authenticate users.

## Check current auth state {:#auth-state}

Firebase Auth provides many methods and utilities for enabling you to integrate
secure authentication into your new or existing Flutter application. In many
cases, you will need to know about the authentication _state_ of your user,
such as whether they're logged in or logged out.

Firebase Auth enables you to subscribe in realtime to this state via a
[`Stream`](https://api.flutter.dev/flutter/dart-async/Stream-class.html).
Once called, the stream provides an immediate event of the user's current
authentication state, and then provides subsequent events whenever
the authentication state changes.

There are three methods for listening to authentication state changes:

### `authStateChanges()`

To subscribe to these changes, call the `authStateChanges()` method on your
`FirebaseAuth` instance:

```dart
FirebaseAuth.instance
  .authStateChanges()
  .listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });
```

Events are fired when the following occurs:

- Right after the listener has been registered.
- When a user is signed in.
- When the current user is signed out.

### `idTokenChanges()`

To subscribe to these changes, call the `idTokenChanges()` method on your
`FirebaseAuth` instance:

```dart
FirebaseAuth.instance
  .idTokenChanges()
  .listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });
```

Events are fired when the following occurs:

- Right after the listener has been registered.
- When a user is signed in.
- When the current user is signed out.
- When there is a change in the current user's token.

{{'<aside>'}}
If you set custom claims using the Firebase Admin SDK,
you will only see this event fire when the following occurs:

- A user signs in or re-authenticates after the custom claims are modified. The
  ID token issued as a result will contain the latest claims.
- An existing user session gets its ID token refreshed after an older token expires.
- An ID token is force refreshed by calling `FirebaseAuth.instance.currentUser.getIdTokenResult(true)`.

For further details, see [Propagating custom claims to the client](/docs/auth/admin/custom-claims#propagate_custom_claims_to_the_client)
  {{'</aside>'}}


### `userChanges()`

To subscribe to these changes, call the `userChanges()` method on your
`FirebaseAuth` instance:

```dart
FirebaseAuth.instance
  .userChanges()
  .listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });
```

Events are fired when the following occurs:

- Right after the listener has been registered.
- When a user is signed in.
- When the current user is signed out.
- When there is a change in the current user's token.
- When the following methods provided by `FirebaseAuth.instance.currentUser` are called:
    * `reload()`
    * `unlink()`
    * `updateEmail()`
    * `updatePassword()`
    * `updatePhoneNumber()`
    * `updateProfile()`

{{'<aside>'}}
`idTokenChanges()`, `userChanges()` & `authStateChanges()` will not fire if you
update the `User` profile with the Firebase Admin SDK. You will have to force a
reload using `FirebaseAuth.instance.currentUser.reload()` to retrieve the latest
`User` profile.

`idTokenChanges()`, `userChanges()` & `authStateChanges()` will also not fire
if you disable or delete the `User` with the Firebase Admin SDK or the Firebase
console. You will have to force a reload using
`FirebaseAuth.instance.currentUser.reload()`, which will cause a `user-disabled`
or `user-not-found` exception that you can catch and handle in your app code.
{{'</aside>'}}


## Persisting authentication state

The Firebase SDKs for all platforms provide out of the box support for ensuring
that your user's authentication state is persisted across app restarts or page
reloads.

On native platforms such as Android & iOS, this behavior is not configurable
and the user's authentication state will be persisted on device between app
restarts. The user can clear the apps cached data using the device settings,
which will wipe any existing state being stored.

On web platforms, the user's authentication state is stored in
[IndexedDB](https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API).
You can change the persistence to store data in the [local storage](https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage)
using `Persistence.LOCAL`.
If required, you can change this default behavior to only persist
authentication state for the current session, or not at all. To configure these
settings, call the following method `FirebaseAuth.instanceFor(app: Firebase.app(), persistence: Persistence.LOCAL);`.
You can still update the persistence for each Auth instance using `setPersistence(Persistence.NONE)`.

```dart
// Disable persistence on web platforms. Must be called on initialization:
final auth = FirebaseAuth.instanceFor(app: Firebase.app(), persistence: Persistence.NONE);
// To change it after initialization, use `setPersistence()`:
await auth.setPersistence(Persistence.LOCAL);
```

## Next Steps

Explore the guides on signing in and signing up users with the supported
identity and authentication services.
