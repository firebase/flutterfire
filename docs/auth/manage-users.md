Project: /docs/_project.yaml
Book: /docs/_book.yaml

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Manage Users in Firebase

## Create a user

You create a new user in your Firebase project in four ways:

- Call the `createUserWithEmailAndPassword()` method.
- Sign in a user for the first time using a [federated identity provider](/docs/auth/flutter/federated-auth),
  such as Google Sign-In, Facebook Login, or Apple.

You can also create new password-authenticated users from the Authentication
section of the [Firebase console](https://console.firebase.google.com/), on the Users page.

## Get a user's profile

To get a user's profile information, use the properties of `User`. There are
three ways to get a `User` object representing the current user:

- The `authStateChanges`, `idTokenChanges` and `userChanges` streams: your
  listeners will receive the current `User`, or `null` if no user is
  authenticated:

  ```dart
  FirebaseAuth.instance
    .authStateChanges()
    .listen((User? user) {
      if (user != null) {
        print(user.uid);
      }
    });
  ```

  When the app starts, an event fires after the user credentials (if any) from
  local storage have been restored, meaning that your listeners always get
  called when the user state is initialized. Then, whenever the authentication
  state changes, a new event will be raised with the updated user state.

  By listening to the authentication state, you can build a user interface that
  reacts to these changes in authentication state.

- The `UserCredential` object returned by the authentication (`signIn`-)
  methods: the `UserCredential` object has a `user` property with the current
  `User`:

  ```dart
  final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
  final user = userCredential.user;
  print(user?.uid);
  ```

- The `currentUser` property of the `FirebaseAuth` instance: if you are sure the
  user is currently signed-in, you can access the `User` from the `currentUser`
  property:

  ```dart
  if (FirebaseAuth.instance.currentUser != null) {
    print(FirebaseAuth.instance.currentUser?.uid);
  }
  ```

  The `currentUser` can be `null` for two reasons:

  - The user isn't signed in.
  - The auth object has not finished initializing. If you use a listener to keep
    track of the user's sign-in status, you don't need to handle this case.


## Get a user's provider-specific profile information

To get the profile information retrieved from the sign-in providers linked to a
user, use the `providerData` property. For example:

```dart
if (user != null) {
    for (final providerProfile in user.providerData) {
        // ID of the provider (google.com, apple.com, etc.)
        final provider = providerProfile.providerId;

        // UID specific to the provider
        final uid = providerProfile.uid;

        // Name, email address, and profile photo URL
        final name = providerProfile.displayName;
        final emailAddress = providerProfile.email;
        final profilePhoto = providerProfile.photoURL;
    }
}
```

## Update a user's profile

You can update a user's basic profile information&mdash;the user's display name
and profile photo URL&mdash;with the `update`- methods. For example:

```dart
await user?.updateDisplayName("Jane Q. User");
await user?.updatePhotoURL("https://example.com/jane-q-user/profile.jpg");
```

## Set a user's email address

You can set a user's email address with the `updateEmail()` method. For example:

```dart
await user?.updateEmail("janeq@example.com");
```

Note: To set a user's email address, the user must have signed in recently.
See [Re-authenticate a user](#re-authenticate_a_user).

## Send a user a verification email {:#verify-email}

You can send an address verification email to a user with the
`sendEmailVerification()` method. For example:

```dart
await user?.sendEmailVerification();
```

You can customize the email template that is used in Authentication section of
the [Firebase console](https://console.firebase.google.com/), on the Email Templates page.
See [Email Templates](https://support.google.com/firebase/answer/7000714) in
Firebase Help Center.

It is also possible to pass state via a
[continue URL](passing-state-in-email-actions) to redirect back
to the app when sending a verification email.

Additionally you can localize the verification email by updating the language
code on the Auth instance before sending the email. For example:

```dart
await FirebaseAuth.instance.setLanguageCode("fr");
await user?.sendEmailVerification();
```

## Set a user's password

You can set a user's password with the `updatePassword()` method. For example:

```dart
await user?.updatePassword(newPassword);
```

Important: To set a user's email address, the user must have signed in recently.
See [Re-authenticate a user](#re-authenticate_a_user).

## Send a password reset email

You can send a password reset email to a user with the `sendPasswordResetEmail()`
method. For example:

```dart
await FirebaseAuth.instance
    .sendPasswordResetEmail(email: "user@example.com");
```

You can customize the email template that is used in Authentication section of
the [Firebase console](https://console.firebase.google.com/), on the Email Templates page.
See [Email Templates](https://support.google.com/firebase/answer/7000714) in
Firebase Help Center.

It is also possible to pass state via a
[continue URL](/docs/auth/android/passing-state-in-email-actions) to redirect back
to the app when sending a password reset email.

Additionally you can localize the password reset email by updating the language
code on the Auth instance before sending the email. For example:

```dart
await FirebaseAuth.instance.setLanguageCode("fr");
```

You can also send password reset emails from the Firebase console.

## Delete a user

You can delete a user account with the `delete()` method. For example:

```dart
await user?.delete();
```

Important: To set a user's email address, the user must have signed in recently.
See [Re-authenticate a user](#re-authenticate_a_user).


You can also delete users from the Authentication section of the
[Firebase console](https://console.firebase.google.com/), on the Users page.

## Re-authenticate a user

Some security-sensitive actions&mdash;such as
[deleting an account](#delete_a_user),
[setting a primary email address](#set_a_users_email_address), and
[changing a password](#set_a_users_password)&mdash;require that the user has
recently signed in. If you perform one of these actions, and the user signed in
too long ago, the action fails and throws a `FirebaseAuthException` with the code
`requires-recent-login`.
When this happens, re-authenticate the user by getting new sign-in credentials
from the user and passing the credentials to `reauthenticate`. For example:

```dart
// Prompt the user to re-provide their sign-in credentials.
// Then, use the credentials to reauthenticate:
await user?.reauthenticateWithCredential(credential);
```

## Import user accounts

You can import user accounts from a file into your Firebase project by using the
Firebase CLI's [`auth:import`](/docs/cli/auth-import) command. For example:

```bash
firebase auth:import users.json --hash-algo=scrypt --rounds=8 --mem-cost=14
```
