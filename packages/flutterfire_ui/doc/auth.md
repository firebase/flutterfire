# FlutterFire UI for Auth

FlutterFire UI for Auth provides a simple and easy way to implement authentication in your Flutter app.
The library provides fully featured UI screens to drop into new or existing applications, along with
lower level implementation details for developers looking for tighter control.

## Installation

See [Getting started with FlutterFireUI](./getting_started.md) guide.

Install dependencies.

```sh
flutter pub add firebase_auth
```

If you want to handle sign in via email link and in-app email verification, you also need to install [firebase_dynamic_links](https://pub.dev/packages/firebase_dynamic_links).

```sh
flutter pub add firebase_dynamic_links
```

## Next steps

To understand what Flutter UI for Auth offers, the following documentation pages walk you through the various topics on
how to use the package within your Flutter app.

- Available auth providers:

  - [EmaiAuthProvider](./auth/providers/email.md) - allows to register and sign in using email and password.
  - [EmailLinkAuthProvider](./auth/providers/email-link.md) - allows to register and sign in using a link sent to email.
  - [PhoneAuthProvider](./auth/providers/phone.md) - allows to register and sign in using a phone number
  - [UniversalEmailSignInProvider](./auth/providers/universal-email-sign-in.md) - gets all connected auth providers for a given email.
  - [OAuth](./auth/providers/oauth.md)

- [Localization](./auth/localization.md)
- [Theming](./auth/theming.md)
- [Navigation](./auth/navigation.md)
