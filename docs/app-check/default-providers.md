Project: /docs/_project.yaml
Book: /docs/_book.yaml

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Get started using App Check in Flutter apps

This page shows you how to enable App Check in a Flutter app, using the
default providers: Play Integrity on Android, Device Check on Apple platforms, and
reCAPTCHA v3 on web. When you enable App Check, you help ensure that
only your app can access your project's Firebase resources. See an
[Overview](/docs/app-check) of this feature.


## 1. Set up your Firebase project {:#project-setup}

1.  [Install and initialize FlutterFire](/docs/flutter/setup) if you haven't
    already done so.

1.  Register your apps to use App Check with the Play Integrity, Device Check, and reCAPTCHA providers in the
    [**Project Settings > App Check**](https://console.firebase.google.com/project/_/appcheck)
    section of the Firebase console.

    You usually need to register all of your project's apps, because once you
    enable enforcement for a Firebase product, only registered apps will be able
    to access the product's backend resources.

1.  **Optional**: In the app registration settings, set a custom time-to-live
    (TTL) for App Check tokens issued by the provider. You can set the TTL
    to any value between 30 minutes and 7 days. When changing this value, be
    aware of the following tradeoffs:

    - Security: Shorter TTLs provide stronger security, because it reduces the
      window in which a leaked or intercepted token can be abused by an
      attacker.
    - Performance: Shorter TTLs mean your app will perform attestation more
      frequently. Because the app attestation process adds latency to network
      requests every time it's performed, a short TTL can impact the performance
      of your app.
    - Quota and cost: Shorter TTLs and frequent re-attestation deplete your
      quota faster, and for paid services, potentially cost more.
      See [Quotas &amp; limits](/docs/app-check#quotas_limits).

    The default TTL
    is reasonable for most apps. Note that the App Check library refreshes
    tokens at approximately half the TTL duration.


## 2. Add the App Check library to your app {:#install-sdk}

1.  From the root of your Flutter project, run the following command to install the plugin:

    ```bash
    flutter pub add firebase_app_check
    ```

1.  Once complete, rebuild your Flutter application:

    ```bash
    flutter run
    ```


## 3. Initialize App Check {:#initialize}

Add the following initialization code to your app so that it runs before you
use any Firebase services such as Storage, but after calling
`Firebase.initializeApp()`;

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// Import the firebase_app_check plugin
import 'package:firebase_app_check/firebase_app_check.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    webRecaptchaSiteKey: 'recaptcha-v3-site-key',
    // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. debug provider
    // 2. safety net provider
    // 3. play integrity provider
    androidProvider: AndroidProvider.debug,
  );
  runApp(App());
}
```

## Next steps

Once the App Check library is installed in your app, start distributing the
updated app to your users.

The updated client app will begin sending App Check tokens along with every
request it makes to Firebase, but Firebase products will not require the tokens
to be valid until you enable enforcement in the App Check section of the
Firebase console.

### Monitor metrics and enable enforcement {:#monitor}

Before you enable enforcement, however, you should make sure that doing so won't
disrupt your existing legitimate users. On the other hand, if you're seeing
suspicious use of your app resources, you might want to enable enforcement
sooner.

To help make this decision, you can look at App Check metrics for the
services you use:

- [Monitor App Check request metrics](/docs/app-check/monitor-metrics) for
  Realtime Database, Cloud Firestore, and Cloud Storage.
- [Monitor App Check request metrics for Cloud Functions](/docs/app-check/monitor-functions-metrics).

### Enable App Check enforcement {:#enforce}

When you understand how App Check will affect your users and you're ready to
proceed, you can enable App Check enforcement:

- [Enable App Check enforcement](/docs/app-check/enable-enforcement) for
  Realtime Database, Cloud Firestore, and Cloud Storage.
- [Enable App Check enforcement for Cloud Functions](/docs/app-check/cloud-functions).

### Use App Check in debug environments {:#debug}

If, after you have registered your app for App Check, you want to run your
app in an environment that App Check would normally not classify as valid,
such as an emulator during development, or from a continuous integration (CI)
environment, you can create a debug build of your app that uses the
App Check debug provider instead of a real attestation provider.

See [Use App Check with the debug provider in Flutter apps](/docs/app-check/flutter/debug-provider).
