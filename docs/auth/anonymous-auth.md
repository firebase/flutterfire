Project: /docs/_project.yaml
Book: /docs/_book.yaml

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Authenticate with Firebase Anonymously

You can use Firebase Authentication to create and use temporary anonymous accounts
to authenticate with Firebase. These temporary anonymous accounts can be used to
allow users who haven't yet signed up to your app to work with data protected
by security rules. If an anonymous user decides to sign up to your app, you can
[link their sign-in credentials](account-linking) to the anonymous account so
that they can continue to work with their protected data in future sessions.

## Before you begin

1.  If you haven't already, follow the steps in the [Get started](start) guide.

1.  Enable Anonymous sign-in:

    - In the Firebase console's **Authentication** section, open the
      [Sign in method](https://console.firebase.google.com/project/_/authentication/providers)
      page.
    - From the **Sign in method** page, enable the **Anonymous sign-in**
      method and click **Save**.

## Authenticate with Firebase anonymously

When a signed-out user uses an app feature that requires authentication with
Firebase, sign in the user anonymously by calling `signInAnonymously()`:

```dart
try {
  final userCredential =
      await FirebaseAuth.instance.signInAnonymously();
  print("Signed in with temporary account.");
} on FirebaseAuthException catch (e) {
  switch (e.code) {
    case "operation-not-allowed":
      print("Anonymous auth hasn't been enabled for this project.");
      break;
    default:
      print("Unknown error.");
  }
}
```

Note: To protect your project from abuse, Firebase limits the number of new
email/password and anonymous sign-ups that your application can have from the
same IP address in a short period of time. You can request and schedule
temporary changes to this quota from the
[Firebase console](https://console.firebase.google.com/project/_/authentication/providers).

## Convert an anonymous account to a permanent account

When an anonymous user signs up to your app, you might want to allow them to
continue their work with their new account&mdash;for example, you might want to
make the items the user added to their shopping cart before they signed up
available in their new account's shopping cart. To do so, complete the following
steps:

1.  When the user signs up, complete the sign-in flow for the user's
    authentication provider up to, but not including, calling one of the
    `signInWith`- methods. For example, get the user's Google ID token,
    Facebook access token, or email address and password.

1.  Get a `Credential` object for the new authentication provider:

    ```dart
    // Google Sign-in
    final credential = GoogleAuthProvider.credential(idToken: idToken);

    // Email and password sign-in
    final credential =
        EmailAuthProvider.credential(email: emailAddress, password: password);

    // Etc.
    ```

1.  Pass the `Credential` object to the sign-in user's `linkWithCredential()`
    method:

    ```dart
    try {
      final userCredential = await FirebaseAuth.instance.currentUser
          ?.linkWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "provider-already-linked":
          print("The provider has already been linked to the user.");
          break;
        case "invalid-credential":
          print("The provider's credential is not valid.");
          break;
        case "credential-already-in-use":
          print("The account corresponding to the credential already exists, "
              "or is already linked to a Firebase User.");
          break;
        // See the API reference for the full list of error codes.
        default:
          print("Unknown error.");
      }
      ```

If the call to `linkWithCredential()` succeeds, the user's new account can
access the anonymous account's Firebase data.

Note: This technique can also be used to [link any two accounts](account-linking).


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
