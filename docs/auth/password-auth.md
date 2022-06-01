Project: /docs/_project.yaml
Book: /docs/_book.yaml

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Authenticate with Firebase using Password-Based Accounts on Flutter

You can use Firebase Authentication to let your users authenticate with
Firebase using email addresses and passwords.

## Before you begin

1.  If you haven't already, follow the steps in the [Get started](start) guide.

1.  Enable Email/Password sign-in:

    - In the Firebase console's **Authentication** section, open the
      [Sign in method](https://console.firebase.google.com/project/_/authentication/providers)
      page.
    - From the **Sign in method** page, enable the **Email/password sign-in**
      method and click **Save**.

## Create a password-based account

To create a new user account with a password, call the `createUserWithEmailAndPassword()`
method:

```dart
try {
  final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: emailAddress,
    password: password,
  );
} on FirebaseAuthException catch (e) {
  if (e.code == 'weak-password') {
    print('The password provided is too weak.');
  } else if (e.code == 'email-already-in-use') {
    print('The account already exists for that email.');
  }
} catch (e) {
  print(e);
}
```

Typically, you would do this from your app's sign-up screen. When a new user
signs up using your app's sign-up form, complete any new account validation
steps that your app requires, such as verifying that the new account's password
was correctly typed and meets your complexity requirements.

If the new account was created successfully, the user is also signed in. If you
are listening to changes in [authentication state](start#auth-state), a new
event will be sent to your listeners.

As a follow-up to creating a new account, you can
[Verify the user's email address](manage-users#verify-email).

Note: To protect your project from abuse, Firebase limits the number of new
email/password and anonymous sign-ups that your application can have from the
same IP address in a short period of time. You can request and schedule
temporary changes to this quota from the
[Firebase console](https://console.firebase.google.com/project/_/authentication/providers).

## Sign in a user with an email address and password

The steps for signing in a user with a password are similar to the steps for
creating a new account. From your your app's sign-in screen, call
`signInWithEmailAndPassword()`:

```dart
try {
  final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: emailAddress,
    password: password
  );
} on FirebaseAuthException catch (e) {
  if (e.code == 'user-not-found') {
    print('No user found for that email.');
  } else if (e.code == 'wrong-password') {
    print('Wrong password provided for that user.');
  }
}
```

Caution: When a user uninstalls your app on iOS or macOS, the user's authentication
state can persist between app re-installs, as the Firebase iOS SDK persists
authentication state to the system keychain.
See issue [#4661](https://github.com/firebase/flutterfire/issues/4661)
for more information.


## Next steps

After a user creates a new account, this account is stored as part of your
Firebase project, and can be used to identify a user across every app in your
project, regardless of what sign-in method the user used.

In your apps, you can get the user's basic profile information from the
`User` object. See [Manage Users](manage-users).

In your Firebase Realtime Database and Cloud Storage Security Rules, you can
get the signed-in user's unique user ID from the `auth` variable, and use it to
control what data a user can access.

You can allow users to sign in to your app using multiple authentication
providers by [linking auth provider credentials](account-linking)) to an
existing user account.

To sign out a user, call `signOut()`:

```dart
await FirebaseAuth.instance.signOut();
```
