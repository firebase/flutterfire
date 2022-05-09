Project: /docs/_project.yaml
Book: /docs/_book.yaml

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Link Multiple Auth Providers to an Account

You can allow users to sign in to your app using multiple authentication
providers by linking auth provider credentials to an existing user account.
Users are identifiable by the same Firebase user ID regardless of the
authentication provider they used to sign in. For example, a user who signed in
with a password can link a Google account and sign in with either method in the
future. Or, an anonymous user can link a Facebook account and then, later, sign
in with Facebook to continue using your app.

## Before you begin

Add support for two or more authentication providers (possibly including
anonymous authentication) to your app.

## Link auth provider credentials to a user account

To link auth provider credentials to an existing user account:

1.  Sign in the user using any authentication provider or method.

1.  Complete the sign-in flow for the new authentication provider up to, but not
    including, calling one of the `signInWith`- methods. For example, get
    the user's Google ID token, Facebook access token, or email and password.

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

If the call to `linkWithCredential()` succeeds, the user can now sign in using
any linked authentication provider and access the same Firebase data.

## Unlink an auth provider from a user account

You can unlink an auth provider from an account, so that the user can no
longer sign in with that provider.

To unlink an auth provider from a user account, pass the provider ID to the
`unlink()` method. You can get the provider IDs of the auth providers linked to
a user from the `User` object's `providerData` property.

```dart
try {
  await FirebaseAuth.instance.currentUser?.unlink(providerId);
} on FirebaseAuthException catch (e) {
  switch (e.code) {
    case "no-such-provider":
      print("The user isn't linked to the provider or the provider "
          "doesn't exist.");
      break;
    default:
      print("Unkown error.");
  }
}
```
