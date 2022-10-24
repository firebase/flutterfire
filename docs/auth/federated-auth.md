Project: /docs/_project.yaml
Book: /docs/_book.yaml

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Federated identity & social sign-in

Social authentication is a multi-step authentication flow, allowing you to sign a user into an account or link
them with an existing one.

Both native platforms and web support creating a credential which can then be passed to the `signInWithCredential`
or `linkWithCredential` methods. Alternatively on web platforms, you can trigger the authentication process via
a popup or redirect.

## Google

Most configuration is already setup when using Google Sign-In with Firebase, however you need to ensure your machine's
SHA1 key has been configured for use with Android. You can see how to generate the key in the
[authentication documentation](https://developers.google.com/android/guides/client-auth).

Ensure the "Google" sign-in provider is enabled on the [Firebase Console](https://console.firebase.google.com/project/_/authentication/providers).

> If your user signs in with Google, after having already manually registered an account, their authentication provider will automatically
> change to Google, due to Firebase Authentications concept of trusted providers. You can find out more about
> this [here](https://groups.google.com/g/firebase-talk/c/ms_NVQem_Cw/m/8g7BFk1IAAAJ).

* {iOS+ and Android}

  On native platforms, a 3rd party library is required to trigger the authentication flow.

  Install the official [`google_sign_in`](https://pub.dev/packages/google_sign_in) plugin.

  Once installed, trigger the sign-in flow and create a new credential:

  ```dart
  import 'package:google_sign_in/google_sign_in.dart';

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
  ```

* {Web}

  On the web, the Firebase SDK provides support for automatically handling the authentication flow using your Firebase project. For example:

  Create a Google auth provider, providing any additional [permission scope](https://developers.google.com/identity/protocols/oauth2/scopes)
  you wish to obtain from the user:

  ```dart
  GoogleAuthProvider googleProvider = GoogleAuthProvider();

  googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');
  googleProvider.setCustomParameters({
    'login_hint': 'user@example.com'
  });
  ```

  Provide the credential to the `signInWithPopup` method. This will trigger a new
  window to appear prompting the user to sign-in to your project. Alternatively you can use `signInWithRedirect` to keep the
  authentication process in the same window.

  ```dart
  Future<UserCredential> signInWithGoogle() async {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');
    googleProvider.setCustomParameters({
      'login_hint': 'user@example.com'
    });

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithPopup(googleProvider);

    // Or use signInWithRedirect
    // return await FirebaseAuth.instance.signInWithRedirect(googleProvider);
  }
  ```

## Google Play Games {:#games}

You can authenticate users in your Android game using Play Games Sign-In.

* {Android}

  Follow the instructions for Google setup on Android, then configure 
  [Play Games services with your Firebase app information](https://firebase.google.com/docs/auth/android/play-games#configure-play-games-with-firebase-info).

  The following will trigger the sign-in flow, create a new credential and sign in the user:

  ```dart
  final googleUser = await GoogleSignIn(
    signInOption: SignInOption.games,
  ).signIn();

  final googleAuth = await googleUser?.authentication;

  if (googleAuth != null) {
    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    await _auth.signInWithCredential(credential);
  }
  ```



## Facebook

Before getting started setup your [Facebook Developer App](https://developers.facebook.com/apps/) and follow the setup process to enable Facebook Login.

Ensure the "Facebook" sign-in provider is enabled on the [Firebase Console](https://console.firebase.google.com/project/_/authentication/providers).
with the Facebook App ID and Secret set.

* {iOS+ and Android}

  On native platforms, a 3rd party library is required to both install the Facebook SDK and trigger the authentication flow.

  Install the [`flutter_facebook_auth`](https://pub.dev/packages/flutter_facebook_auth) plugin.

  You will need to follow the steps in the plugin documentation to ensure that both the Android & iOS Facebook SDKs have been initialized
  correctly. Once complete, trigger the sign-in flow, create a Facebook credential and sign the user in:

  ```dart
  import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

  Future<UserCredential> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken.token);

    // Once signed in, return the UserCredential
    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }
  ```

* {Web}

  On the web, the Firebase SDK provides support for automatically handling the authentication flow using the
  Facebook application details provided on the Firebase console. For example:

  Create a Facebook provider, providing any additional [permission scope](https://developers.facebook.com/docs/facebook-login/permissions/)
  you wish to obtain from the user.

  Ensure that the OAuth redirect URI from the Firebase console is added as a valid OAuth Redirect URI
  in your Facebook App.

  ```dart
  FacebookAuthProvider facebookProvider = FacebookAuthProvider();

  facebookProvider.addScope('email');
  facebookProvider.setCustomParameters({
    'display': 'popup',
  });
  ```

  Provide the credential to the `signInWithPopup` method. This will trigger a new
  window to appear prompting the user to sign-in to your Facebook application:

  ```dart
  Future<UserCredential> signInWithFacebook() async {
    // Create a new provider
    FacebookAuthProvider facebookProvider = FacebookAuthProvider();

    facebookProvider.addScope('email');
    facebookProvider.setCustomParameters({
      'display': 'popup',
    });

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithPopup(facebookProvider);

    // Or use signInWithRedirect
    // return await FirebaseAuth.instance.signInWithRedirect(facebookProvider);
  }
  ```

Note: Firebase will not set the `User.emailVerified` property
to `true` if your user logs in with Facebook. Should your user login using a provider that verifies email (e.g. Google sign-in) then this will be set to true.
For further information, see this [issue](https://github.com/firebase/flutterfire/issues/4612#issuecomment-782107867).


## Apple

* {iOS+}

  Before you begin, [configure Sign In with Apple](/docs/auth/ios/apple#configure-sign-in-with-apple)
  and [enable Apple as a sign-in provider](/docs/auth/ios/apple#enable-apple-as-a-sign-in-provider).

  Next, make sure that your `Runner` apps have the "Sign in with Apple" capability.

* {Android}
  Before you begin, [configure Sign In with Apple](/docs/auth/android/apple#configure_sign_in_with_apple)
  and [enable Apple as a sign-in provider](/docs/auth/android/apple#enable-apple-as-a-sign-in-provider).

* {Web}

  Before you begin, [configure Sign In with Apple](/docs/auth/web/apple#configure-sign-in-with-apple)
  and [enable Apple as a sign-in provider](/docs/auth/web/apple#enable-apple-as-a-sign-in-provider).


```dart
import 'package:firebase_auth/firebase_auth.dart';

Future<UserCredential> signInWithApple() async {
  final appleProvider = AppleAuthProvider();
  if (kIsWeb) {
    await FirebaseAuth.instance.signInWithPopup(appleProvider);
  } else {
    await FirebaseAuth.instance.signInWithProvider(appleProvider);
  }
}
```

## Microsoft

* {iOS+}

  Before you begin [configure Microsoft Login for iOS](/docs/auth/ios/microsoft-oauth#before_you_begin) and add the [custom URL schemes
  to your Runner (step 1)](https://firebase.google.com/docs/auth/ios/microsoft-oauth#handle_the_sign-in_flow_with_the_firebase_sdk).

* {Android}
  Before you begin [configure Microsoft Login for Android](/docs/auth/android/microsoft-oauth#before_you_begin).
  
  Don't forget to add your app's SHA-1 fingerprint.

* {Web}

  Before you begin [configure Microsoft Login for Web](/docs/auth/web/microsoft-oauth#configure-sign-in-with-apple).

```dart
import 'package:firebase_auth/firebase_auth.dart';

Future<UserCredential> signInWithMicrosoft() async {
  final microsoftProvider = MicrosoftAuthProvider();
  if (kIsWeb) {
    await FirebaseAuth.instance.signInWithPopup(microsoftProvider);
  } else {
    await FirebaseAuth.instance.signInWithProvider(microsoftProvider);
  }
}
```

## Twitter

Ensure the "Twitter" sign-in provider is enabled on the [Firebase Console](https://console.firebase.google.com/project/_/authentication/providers)
with an API Key and API Secret set. Ensure your Firebase OAuth redirect URI (e.g. my-app-12345.firebaseapp.com/__/auth/handler) 
is set as your Authorization callback URL in your app's settings page on your [Twitter app's config](https://apps.twitter.com/).

You also might need to request elevated [API access depending on your app](https://developer.twitter.com/en/portal/products/elevated).

* {iOS+}

  You need to configure your custom URL scheme as [described in iOS guide step 1](https://firebase.google.com/docs/auth/ios/twitter-login#handle_the_sign-in_flow_with_the_firebase_sdk).

* {Android}

  If you haven't yet specified your app's SHA-1 fingerprint, do so from the [Settings page](https://console.firebase.google.com/project/_/settings/general/) 
  of the Firebase console. Refer to [Authenticating Your Client](https://developers.google.com/android/guides/client-auth) for details on how to get your app's SHA-1 fingerprint.

* {Web}

  Works out of the box.

```dart
import 'package:firebase_auth/firebase_auth.dart';

Future<void> _signInWithTwitter() async {
  TwitterAuthProvider twitterProvider = TwitterAuthProvider();

  if (kIsWeb) {
    await FirebaseAuth.instance.signInWithPopup(twitterProvider);
  } else {
    await FirebaseAuth.instance.signInWithProvider(twitterProvider);
  }
}
```


## GitHub

Ensure that you have setup an OAuth App from your [GitHub Developer Settings](https://github.com/settings/developers) and
that the "GitHub" sign-in provider is enabled on the [Firebase Console](https://console.firebase.google.com/project/_/authentication/providers)
with the Client ID and Secret are set, with the callback URL set in the GitHub app.

* {iOS+ and Android}

  For native platforms, you need to add the `google-services.json` and `GoogleService-Info.plist`.

  For iOS, add the custom URL scheme as [described on the iOS guide](https://firebase.google.com/docs/auth/ios/github-auth#handle_the_sign-in_flow_with_the_firebase_sdk) step 1.

  ```dart
  Future<UserCredential> signInWithGitHub() async {
    // Create a new provider
    GithubAuthProvider githubProvider = GithubAuthProvider();

    return await FirebaseAuth.instance.signInWithProvider(githubProvider);
  }
  ```

* {Web}

  On the web, the GitHub SDK provides support for automatically handling the authentication flow using the
  GitHub application details provided on the Firebase console. Ensure that the callback URL in the Firebase console is added
  as a callback URL in your GitHub application on the developer console.

  For example:

  Create a GitHub provider and provide the credential to the `signInWithPopup` method. This will trigger a new
  window to appear prompting the user to sign-in to your GitHub application:

  ```dart
  Future<UserCredential> signInWithGitHub() async {
    // Create a new provider
    GithubAuthProvider githubProvider = GithubAuthProvider();

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithPopup(githubProvider);

    // Or use signInWithRedirect
    // return await FirebaseAuth.instance.signInWithRedirect(githubProvider);
  }
  ```



## Yahoo

Ensure the "Yahoo" sign-in provider is enabled on the [Firebase Console](https://console.firebase.google.com/project/_/authentication/providers)
with an API Key and API Secret set. Also make sure your Firebase OAuth redirect URI (e.g. my-app-12345.firebaseapp.com/__/auth/handler) 
is set as a redirect URI in your app's Yahoo Developer Network configuration.


* {iOS+}

  Before you begin, [configure Yahoo Login for iOS](/docs/auth/ios/yahoo-oauth#before_you_begin) and add the [custom URL schemes
  to your Runner (step 1)](https://firebase.google.com/docs/auth/ios/yahoo-oauth#handle_the_sign-in_flow_with_the_firebase_sdk).

* {Android}
  Before you begin, [configure Yahoo Login for Android](/docs/auth/android/yahoo-oauth#before_you_begin).
  
  Don't forget to add your app's SHA-1 fingerprint.

* {Web}

  Works out of the box.

```dart
import 'package:firebase_auth/firebase_auth.dart';

Future<UserCredential> signInWithYahoo() async {
  final yahooProvider = YahooAuthProvider();
  if (kIsWeb) {
    await _auth.signInWithPopup(yahooProvider);
  } else {
    await _auth.signInWithProvider(yahooProvider);
  }
}
```

# Using the OAuth access token

By using an AuthProvider, you can retrieve the access token associated with the provider
by making the following request.

```dart
final appleProvider = AppleAuthProvider();

final user = await FirebaseAuth.instance.signInWithProvider(appleProvider);
final accessToken = user.credential?.accessToken;

// You can send requests with the `accessToken`
```


# Linking an Authentication Provider

If you want to link a provider to a current user, you can use the following method:
```dart
await FirebaseAuth.instance.signInAnonymously();

final appleProvider = AppleAuthProvider();

if (kIsWeb) {
  await FirebaseAuth.instance.currentUser?.linkWithPopup(appleProvider);
  
  // You can also use `linkWithRedirect`
} else {
  await FirebaseAuth.instance.currentUser?.linkWithProvider(appleProvider);
}

// You're anonymous user is now upgraded to be able to connect with Sign In With Apple
```

# Reauthenticate with provider

The same pattern can be used with `reauthenticateWithProvider` which can be used to retrieve fresh
credentials for sensitive operations that require recent login.

```dart
final appleProvider = AppleAuthProvider();

if (kIsWeb) {
  await FirebaseAuth.instance.currentUser?.reauthenticateWithPopup(appleProvider);
  
  // Or you can reauthenticate with a redirection
  // await FirebaseAuth.instance.currentUser?.reauthenticateWithRedirect(appleProvider);
} else {
  await FirebaseAuth.instance.currentUser?.reauthenticateWithProvider(appleProvider);
}

// You can now perform sensitive operations
```
