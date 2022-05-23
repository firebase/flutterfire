Project: /docs/_project.yaml
Book: /docs/_book.yaml

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Authenticate with Firebase Using a Custom Authentication System

You can integrate Firebase Authentication with a custom authentication system by
modifying your authentication server to produce custom signed tokens when a user
successfully signs in. Your app receives this token and uses it to authenticate
with Firebase.

## Before you begin

1.  If you haven't already, follow the steps in the [Get started](start) guide.
1.  [Install and configure the Firebase Admin SDK](/docs/admin/setup).
    Be sure to [initialize the SDK](/docs/admin/setup#initialize-sdk)
    with the correct credentials for your Firebase project.

## Authenticate with Firebase

1.  When users sign in to your app, send their sign-in credentials (for
    example, their username and password) to your authentication server. Your
    server checks the credentials and, if they are valid,
    [creates a custom Firebase token](/docs/auth/admin/create-custom-tokens)
    and sends the token back to your app.

1.  After you receive the custom token from your authentication server, pass it
    to `signInWithCustomToken()` to sign in the user:

    ```dart
    try {
        final userCredential =
            await FirebaseAuth.instance.signInWithCustomToken(token);
        print("Sign-in successful.");
    } on FirebaseAuthException catch (e) {
        switch (e.code) {
            case "invalid-custom-token":
                print("The supplied token is not a Firebase custom auth token.");
                break;
            case "custom-token-mismatch":
                print("The supplied token is for a different Firebase project.");
                break;
            default:
                print("Unkown error.");
        }
    }
    ```

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
