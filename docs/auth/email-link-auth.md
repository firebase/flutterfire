Project: /docs/_project.yaml
Book: /docs/_book.yaml

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Authenticate with Firebase Using Email Links

You can use Firebase Authentication to sign in a user by sending them an email
containing a link, which they can click to sign in. In the process, the user's
email address is also verified.

There are numerous benefits to signing in by email:

* Low friction sign-up and sign-in.
* Lower risk of password reuse across applications, which can undermine security
  of even well-selected passwords.
* The ability to authenticate a user while also verifying that the user is the
  legitimate owner of an email address.
* A user only needs an accessible email account to sign in. No ownership of a
  phone number or social media account is required.
* A user can sign in securely without the need to provide (or remember) a
  password, which can be cumbersome on a mobile device.
* An existing user who previously signed in with an email identifier (password
  or federated) can be upgraded to sign in with just the email. For example, a
  user who has forgotten their password can still sign in without needing to
  reset their password.


## Before you begin

1.  If you haven't already, follow the steps in the [Get started](start) guide.

1.  Enable Email Link sign-in for your Firebase project.

    To sign in users by email link, you must first enable the Email provider
    and Email link sign-in method for your Firebase project:

    1.  In the [Firebase console](https://console.firebase.google.com/), open the **Auth** section.
    1.  On the **Sign in method** tab, enable the **Email/Password** provider.
        Note that email/password sign-in must be enabled to use email link
        sign-in.
    1.  In the same section, enable **Email link (passwordless sign-in)**
        sign-in method.
    1.  Click **Save**.


## Send an authentication link to the user's email address

To initiate the authentication flow, present an interface that prompts the user to provide their email address and then call `sendSignInLinkToEmail()` to request that Firebase send the authentication link to the user's email.

1.  Construct the ActionCodeSettings object, which provides Firebase with instructions on how to construct the email link. Set the following fields:

    * `url`: The deep link to embed and any additional state to be passed along.
      The link's domain has to be present in the Firebase Console list of
      authorized domains, which can be found by going to the Settings tab
      (Authentication -> Settings -> Authorized Domains). The link will redirect
      the user to this URL if the app is not installed on their device and the
      app was not able to be installed.

    * `androidPackageName` and `IOSBundleId`: The apps to use when the sign-in link is opened on an Android or iOS device. Learn more on how to configure Firebase Dynamic Links to open email action links via mobile apps.

    * `handleCodeInApp`: Set to `true`. The sign-in operation has to always be completed in the app unlike other out of band email actions (password reset and email verifications). This is because, at the end of the flow, the user is expected to be signed in and their Auth state persisted within the app.

    * `dynamicLinkDomain`: (Deprecated, use `linkDomain`) When multiple
      custom dynamic link domains are defined for a project, specify which one
      to use when the link is to be opened using a specified mobile app (for
      example, `example.page.link`). Otherwise the first domain is
      automatically selected.

    * `linkDomain`: The optional custom Firebase Hosting domain to use
      when the link is to be opened using a specified mobile app. The domain
      must be configured in Firebase Hosting and owned by the project.
      This cannot be a default Hosting domain (`web.app` or
      `firebaseapp.com`). This replaces the deprecated `dynamicLinkDomain`
      setting.

    ```dart
    var acs = ActionCodeSettings(
        // URL you want to redirect back to. The domain (www.example.com) for this
        // URL must be whitelisted in the Firebase Console.
        url: 'https://www.example.com/finishSignUp?cartId=1234',
        // This must be true
        handleCodeInApp: true,
        iOSBundleId: 'com.example.ios',
        androidPackageName: 'com.example.android',
        // installIfNotAvailable
        androidInstallApp: true,
        // minimumVersion
        androidMinimumVersion: '12');
    ```

2.  Ask the user for their email.

3.  Send the authentication link to the user's email, and save the user's email in case the user completes the email sign-in on the same device.

    ```dart
    var emailAuth = 'someemail@domain.com';
    FirebaseAuth.instance.sendSignInLinkToEmail(
            email: emailAuth, actionCodeSettings: acs)
        .catchError((onError) => print('Error sending email verification $onError'))
        .then((value) => print('Successfully sent email verification'));
    });
    ```


## Complete sign in with the email link

### Security concerns


To prevent a sign-in link from being used to sign in as an unintended user or on
an unintended device, Firebase Auth requires the user's email address to be
provided when completing the sign-in flow. For sign-in to succeed, this email
address must match the address to which the sign-in link was originally sent.

You can streamline this flow for users who open the sign-in link on the same
device they request the link, by storing their email address locally - for
instance using SharedPreferences - when you send the sign-in email. Then,
use this address to complete the flow.
Do not pass the user's email in the redirect URL parameters and reuse it as
this may enable session injections.

After sign-in completion, any previous unverified mechanism of sign-in will be
removed from the user and any existing sessions will be invalidated.
For example, if someone previously created an unverified account with the same
email and password, the user's password will be removed to prevent the
impersonator who claimed ownership and created that unverified account from
signing in again with the unverified email and password.

Also make sure you use an HTTPS URL in production to avoid your link being
potentially intercepted by intermediary servers.

### Complete Sign-in

Firebase Dynamic Links is deprecated; Firebase Hosting is now used to send a sign-in link. Follow the guides for platform specific configuration:

- [Android](https://firebase.google.com/docs/auth/android/email-link-auth#complete-android-signin)
- [iOS](https://firebase.google.com/docs/auth/ios/email-link-auth#complete-apple-signin)
- [Web](https://firebase.google.com/docs/auth/web/email-link-auth#completing_sign-in_in_a_web_page)


### Verify email link and sign in

For sign-in completion via mobile application, the application has to be configured to detect the incoming application link, parse the underlying deep link and then complete the sign-in.

1.  In your link handler, check if the link is meant for email link authentication and, if so, complete the sign-in process.

    ```dart
    // Confirm the link is a sign-in with email link.
    if (FirebaseAuth.instance.isSignInWithEmailLink(emailLink)) {
      try {
        // The client SDK will parse the code from the link for you.
        final userCredential = await FirebaseAuth.instance
            .signInWithEmailLink(email: emailAuth, emailLink: emailLink);

        // You can access the new user via userCredential.user.
        final emailAddress = userCredential.user?.email;

        print('Successfully signed in with email link!');
      } catch (error) {
        print('Error signing in with email link.');
      }
    }
    ```

### Linking/re-authentication with email link

You can also link this method of authentication to an existing user. For example
a user previously authenticated with another provider, such as a phone number,
can add this method of sign-in to their existing account.

The difference would be in the second half of the operation:

```dart
final authCredential = EmailAuthProvider
    .credentialWithLink(email: emailAuth, emailLink: emailLink.toString());
try {
    await FirebaseAuth.instance.currentUser
        ?.linkWithCredential(authCredential);
} catch (error) {
    print("Error linking emailLink credential.");
}
```

This can also be used to re-authenticate an email link user before running a
sensitive operation.

```dart
final authCredential = EmailAuthProvider
    .credentialWithLink(email: emailAuth, emailLink: emailLink.toString());
try {
    await FirebaseAuth.instance.currentUser
        ?.reauthenticateWithCredential(authCredential);
} catch (error) {
    print("Error reauthenticating credential.");
}
```

However, as the flow could end up on a different device where the original user
was not logged in, this flow might not be completed. In that case, an error can
be shown to the user to force them to open the link on the same device. Some
state can be passed in the link to provide information on the type of operation
and the user uid.

## Deprecated: Differentiating email-password from email link {:#differentiating_emailpassword_from_email_link}

If you created your project on or after September 15, 2023, email enumeration
protection is enabled by default. This feature improves the security of your
project's user accounts, but it disables the `fetchSignInMethodsForEmail()`
method, which we formerly recommended to implement identifier-first flows.

Although you can disable email enumeration protection for your project, we
recommend against doing so.

See the documentation on [email enumeration protection](https://cloud.google.com/identity-platform/docs/admin/email-enumeration-protection)
for more details.

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
