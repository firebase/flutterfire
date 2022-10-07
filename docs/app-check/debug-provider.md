Project: /docs/app-check/_project.yaml
Book: /docs/_book.yaml
page_type: guide

{% include "docs/app-check/_local_variables.html" %}
{% include "_shared/firebase/_snippet_include_comment.html" %}

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

## Apple platforms

To use the debug provider while running your app in a simulator interactively
(during development, for example), do the following:

1.  In the file `ios/Runner/AppDelegate.swift` (or `AppDelegate.m`), create and
    set the App Check debug provider factory in Debug builds:

    * {Swift}

      ```swift
      import UIKit
      import Flutter
      import Firebase  // Add the Firebase import.

      @UIApplicationMain
      @objc class AppDelegate: FlutterAppDelegate {
        override func application(
          _ application: UIApplication,
          didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {
          // Use the debug provider in Debug builds:
      #if DEBUG
          let providerFactory = AppCheckDebugProviderFactory()
          AppCheck.setAppCheckProviderFactory(providerFactory)
      #endif

          GeneratedPluginRegistrant.register(with: self)
          return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
      }
      ```

      Tip: Confirm in your Xcode project's Build Settings that it passes the
      `DEBUG` flag to the Swift compiler.

    * {Objective-C}

      ```objc
      #import "AppDelegate.h"
      #import "GeneratedPluginRegistrant.h"
      @import Firebase;  // Add the Firebase import.

      @implementation AppDelegate

      - (BOOL)application:(UIApplication *)application
          didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        // Use the debug provider in Debug builds:
      #if DEBUG
        FIRAppCheckDebugProviderFactory *providerFactory = [[FIRAppCheckDebugProviderFactory alloc] init];
        [FIRAppCheck setAppCheckProviderFactory:providerFactory];
      #endif
        [GeneratedPluginRegistrant registerWithRegistry:self];
        // Override point for customization after application launch.
        return [super application:application didFinishLaunchingWithOptions:launchOptions];
      }

      @end
      ```

1.  Enable debug logging in your Xcode project (v11.0 or newer):

    1.  Open **Product > Scheme > Edit scheme**.
    1.  Select **Run** from the left menu, then select the **Arguments** tab.
    1.  In the **Arguments Passed on Launch** section, add `-FIRDebugEnabled`.

1.  Open `ios/Runner.xcworkspace` with Xcode and run your app in the Simulator.
    Your app will print a local debug token to the debug output when Firebase
    tries to send a request to the backend. For example:

    <pre>[Firebase/AppCheck][I-FAA001001] Firebase App Check Debug Token:
    123a4567-b89c-12d3-e456-789012345678</pre>

{# Google-internal common file: #}
<<../_includes/manage-debug-tokens.md>>

After you register the token, Firebase backend services will accept it as valid.

Because this token allows access to your Firebase resources without a
valid device, it is crucial that you keep it private. Don't commit it to a
public repository, and if a registered token is ever compromised, revoke it
immediately in the Firebase console.

## Android

To use the debug provider while running your Flutter app in an Android environment,
implement the following code in your Flutter application:

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
    // Set androidProvider to `AndroidProvider.debug`
    androidProvider: AndroidProvider.debug,
  );
  runApp(App());
}

```

Your app will print a local debug token to the debug output when Firebase tries
to send a request to the backend. For example:

<pre>D DebugAppCheckProvider: Enter this debug secret into the allow list in
the Firebase Console for your project: 123a4567-b89c-12d3-e456-789012345678</pre>

{# Google-internal common file: #}
<<../_includes/manage-debug-tokens.md>>

After you register the token, Firebase backend services will accept it as valid.

## Web

To use the debug provider while running your app from `localhost` (during
development, for example), do the following:

Warning: _Do not_ try to enable `localhost` debugging by adding `localhost` to
reCAPTCHA’s allowed domains. Doing so would allow anyone to run your app from
their local machines!

1.  In the file `web/index.html`, enable debug mode by setting
    `self.FIREBASE_APPCHECK_DEBUG_TOKEN` to `true`:

    ```html
    <body>
      <script>
        self.FIREBASE_APPCHECK_DEBUG_TOKEN = true;
      </script>

      ...

    </body>
    ```

1.  Run your web app locally and open the browser’s developer tool. In the
    debug console, you’ll see a debug token:

    <pre>AppCheck debug token: "123a4567-b89c-12d3-e456-789012345678". You will
    need to safelist it in the Firebase console for it to work.</pre>

    This token is stored locally in your browser and will be used whenever you
    use your app in the same browser on the same machine. If you want to use the
    token in another browser or on another machine, set
    `self.FIREBASE_APPCHECK_DEBUG_TOKEN` to the token string instead of `true`.

{# Google-internal common file: #}
<<../_includes/manage-debug-tokens.md>>

After you register the token, Firebase backend services will accept it as valid.

Because this token allows access to your Firebase resources without a
valid device, it is crucial that you keep it private. Don't commit it to a
public repository, and if a registered token is ever compromised, revoke it
immediately in the Firebase console.
