Project: /docs/_project.yaml
Book: /docs/_book.yaml

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

#  Use App Check with the debug provider with Flutter

After you have registered your app for App Check, your app normally won't run
in an emulator or from a continuous integration (CI) environment, since those
environments don't qualify as valid devices. If you want to run your app in such
an environment during development and testing, you can create a debug build of
your app that uses the App Check debug provider instead of a real attestation
provider.

Warning: The debug provider allows access to your Firebase resources from
unverified devices. Don't use the debug provider in production builds of your
app, and don't share your debug builds with untrusted parties.

The debug provider does not currently have a Dart API; you'll need to apply the
changes individually for each of your platforms:

- [Use App Check with the debug provider on Apple platforms](/docs/app-check/ios/debug-provider)
- [Use App Check with the debug provider on Android](/docs/app-check/android/debug-provider)
- [Use App Check with the debug provider in web apps](/docs/app-check/web/debug-provider)
