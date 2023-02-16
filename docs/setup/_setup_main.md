{# This content gets published to the following location: #}
{#   https://firebase.google.com/docs/flutter/setup       #}

## **Step 1**: Install the required command line tools {: #install-cli-tools}

1.  If you haven't already,
    [install the {{firebase_cli}}](/docs/cli#setup_update_cli).

1.  Log into Firebase using your Google account by running the following
    command:

    ```sh {: .devsite-terminal .devsite-click-to-copy}
    firebase login
    ```

1.  Install the FlutterFire CLI by running the following command from any
    directory:

    ```sh {: .devsite-terminal .devsite-click-to-copy}
    dart pub global activate flutterfire_cli
    ```


## **Step 2**: Configure your apps to use Firebase {: #configure-firebase}

Use the FlutterFire CLI to configure your Flutter apps to connect to Firebase.

From your Flutter project directory, run the following command to start the
app configuration workflow:

```sh {: .devsite-terminal .devsite-click-to-copy data-terminal-prefix="your-flutter-proj$ " }
flutterfire configure
```

{{ '<section class="expandable">' }}
<p class="showalways">What does this <code>flutterfire configure</code>
  workflow do?
</p>

> The `flutterfire configure` workflow does the following:
>
> * Asks you to select the platforms (iOS, Android, Web) supported in your
>   Flutter app. For each selected platform, the FlutterFire CLI creates a new
>   Firebase app in your Firebase project.
>
>   You can select either to use an existing Firebase project or to create a
>   new Firebase project. If you already have apps registered in an existing
>   Firebase project, the FlutterFire CLI will attempt to match them based on
>   your current Flutter project configuration.
>
>   <aside class="note"><b>Note:</b> Here are some tips about setting up and
>     managing your Firebase project:
>
>     <ul>
>       <li>Check out our
>         <a href="/docs/projects/dev-workflows/general-best-practices">best practices</a>
>         for adding apps to a Firebase project, including how to handle
>         multiple variants.
>       </li>
>       <li><a href="https://support.google.com/firebase/answer/9289399#linkga" class="external">
>         Enable {{firebase_analytics}}</a>
>         in your project, which enables you to have an optimal experience using
>         many Firebase products, like {{crashlytics}} and {{remote_config}}.
>       </li>
>     </ul>
>   </aside>
>
> * Creates a Firebase configuration file (`firebase_options.dart`) and adds it
>   to your `lib/` directory.
>
>   Note: This Firebase config file contains unique, but non-secret
>   identifiers for each platform you selected. <br>Visit [Understand
>   Firebase Projects](/docs/projects/learn-more#config-files-objects) to
>   learn more about this config file.
>
> * _(for {{crashlytics}} or {{perfmon}} on Android)_ Adds the required
>   product-specific Gradle plugins to your Flutter app.
>
>   Note: For the FlutterFire CLI to add the appropriate Gradle plugin, the
>   product's Flutter plugin must already be imported into your Flutter app.

{{ '</section>' }}

<br>

<aside class="caution">After this initial running of
  <code>flutterfire configure</code>, you need to re-run the command any time
  that you:

  <ul>
    <li>Start supporting a new platform in your Flutter app.
    </li>
    <li>Start using a new Firebase service or product in your Flutter app,
      especially if you start using sign-in with Google, {{crashlytics}},
      {{perfmon}}, or {{database}}.
    </li>
  </ul>

  <p>Re-running the command ensures that your Flutter app's Firebase
    configuration is up-to-date and (for Android) automatically adds any
    required Gradle plugins to your app.
</aside>


## **Step 3**: Initialize Firebase in your app {: #initialize-firebase}

1.  From your Flutter project directory, run the following command to install
    the core plugin:

    ```sh {: .devsite-terminal .devsite-click-to-copy data-terminal-prefix="your-flutter-proj$ " }
    flutter pub add firebase_core
    ```

1.  From your Flutter project directory, run the following command to ensure
    that your Flutter app's Firebase configuration is up-to-date:

    ```sh {: .devsite-terminal .devsite-click-to-copy data-terminal-prefix="your-flutter-proj$ " }
    flutterfire configure
    ```

1.  In your `lib/main.dart` file, import the Firebase core plugin and the
    configuration file you generated earlier:

    ```dart
    import 'package:firebase_core/firebase_core.dart';
    import 'firebase_options.dart';
    ```

1.  Also in your `lib/main.dart` file, initialize Firebase using the
    `DefaultFirebaseOptions` object exported by the configuration file:

    ```dart
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    ```

1.  Rebuild your Flutter application:

    ```sh {: .devsite-terminal .devsite-click-to-copy data-terminal-prefix="your-flutter-proj$ " }
    flutter run
    ```

#### Using TrustedTypes for web

If you plan to use Firebase on the web, you can use TrustedTypes to prevent
XSS attacks. If TrustedTypes are enabled, Firebase will inject the
scripts into the DOM using TrustedTypes. The policy name are defined as
follows: 'flutterfire-firease_core', 'flutterfire-firebase_auth'... etc.

## **Step 4**: Add Firebase plugins {: #add-plugins}

You access Firebase in your Flutter app through the various
[Firebase Flutter plugins](#available-plugins), one for each Firebase product
(for example: {{firestore}}, {{auth}}, {{analytics}}, etc.).

Since Flutter is a multi-platform framework, each Firebase plugin is applicable
for Apple, Android, and web platforms. So, if you add any Firebase plugin to
your Flutter app, it will be used by the Apple, Android, and web versions of
your app.

Here's how to add a Firebase Flutter plugin:

1.  From your Flutter project directory, run the following command:

    <pre class="devsite-terminal devsite-click-to-copy" data-terminal-prefix="your-flutter-proj$ ">flutter pub add <var>PLUGIN_NAME</var></pre>

1.  From your Flutter project directory, run the following command:

    ```sh {: .devsite-terminal .devsite-click-to-copy data-terminal-prefix="your-flutter-proj$ " }
    flutterfire configure
    ```

    Running this command ensures that your Flutter app's Firebase configuration
    is up-to-date and, for {{crashlytics}} and {{perfmon}} on Android, adds the
    required Gradle plugins to your app.

1.  Once complete, rebuild your Flutter project:

    ```sh {: .devsite-terminal .devsite-click-to-copy data-terminal-prefix="your-flutter-proj$ " }
    flutter run
    ```

You’re all set! Your Flutter apps are registered and configured to use Firebase.


### Available plugins {: #available-plugins}

{% setvar YES %}<div class="center compare-yes"></div>{% endsetvar %}

Product                                          | Plugin name                    | iOS     | Android | Web     | Other Apple<br>(macOS, etc.)
-------------------------------------------------|--------------------------------|---------|---------|---------|--------------------------
[{{analytics}}][analytics docs]                  | `firebase_analytics`           | {{YES}} | {{YES}} | {{YES}} | beta
[{{app_check}}][app check docs]                  | `firebase_app_check`           | {{YES}} | {{YES}} | {{YES}} | beta
[{{auth}}][auth docs]                            | `firebase_auth`                | {{YES}} | {{YES}} | {{YES}} | beta
[{{firestore}}][firestore docs]                  | `cloud_firestore`              | {{YES}} | {{YES}} | {{YES}} | beta
[{{cloud_functions}}][functions docs]            | `cloud_functions`              | {{YES}} | {{YES}} | {{YES}} | beta
[{{messaging_longer}}][fcm docs]                 | `firebase_messaging`           | {{YES}} | {{YES}} | {{YES}} | beta
[{{storage}}][storage docs]                      | `firebase_storage`             | {{YES}} | {{YES}} | {{YES}} | beta
[{{crashlytics}}][crashlytics docs]              | `firebase_crashlytics`         | {{YES}} | {{YES}} |         | beta
[{{ddls}}][ddls docs]                            | `firebase_dynamic_links`       | {{YES}} | {{YES}} |         |
[{{inappmessaging}}][fiam docs]                  | `firebase_in_app_messaging`    | {{YES}} | {{YES}} |         |
[{{firebase_installations}}][installations docs] | `firebase_app_installations`   | {{YES}} | {{YES}} | {{YES}} | beta
[ML Model Downloader][ml docs]                   | `firebase_ml_model_downloader` | {{YES}} | {{YES}} |         | beta
[{{perfmon}}][perfmon docs]                      | `firebase_performance`         | {{YES}} | {{YES}} | {{YES}} |
[{{database}}][rtdb docs]                        | `firebase_database`            | {{YES}} | {{YES}} | {{YES}} | beta
[{{remote_config}}][remote config docs]          | `firebase_remote_config`       | {{YES}} | {{YES}} | {{YES}} | beta


## Try out an example app with {{analytics}} {: #try-analytics-example-app}

Like all packages, the `firebase_analytics` plugin comes with an
[example program](//github.com/firebase/flutterfire/tree/master/packages/firebase_analytics/firebase_analytics/example){: .external}.

1.  Open a Flutter app that you've already configured to use Firebase (see
    instructions on this page).

1.  Access the `lib` directory of the app, then delete the existing `main.dart`
    file.

1.  From the {{firebase_analytics}}
    [example program repository](//github.com/firebase/flutterfire/tree/master/packages/firebase_analytics/firebase_analytics/example/lib){: .external},
    copy-paste the following two files into your app's `lib` directory:

      * `main.dart`
      * `tabs_page.dart`

1.  Run your Flutter app.

1.  Go to your app's Firebase project in the {{appmanager_link}}, then click
    **Analytics** in the left-nav.

    1.  Click
        [**Dashboard**](//support.google.com/firebase/answer/6317517).
        If {{analytics}} is working properly, the dashboard shows an active user
        in the "Users active in the last 30&nbsp;minutes" panel (this might take
        time to populate this panel).

    1.  Click [**DebugView**](/docs/analytics/debugview). Enable the feature to
        see all the events generated by the example program.

For more information about setting up {{analytics}}, visit the getting started
guides for [iOS+](/docs/analytics/get-started?platform=ios),
[Android](/docs/analytics/get-started?platform=android), and
[web](/docs/analytics/get-started?platform=web).


## Next steps

* Get hands-on experience with the
  [Firebase Flutter Codelab](/codelabs/firebase-get-to-know-flutter).

* Prepare to launch your app:
<<../../../_internal/includes/docs/guides/_prepare-to-launch-app.md>>

{# The above line includes a Google-internal file, which isn't on GitHub. #}

[analytics docs]: /docs/analytics/get-started?platform=flutter
[app check docs]: /docs/app-check/flutter/default-providers
[auth docs]: /docs/auth/flutter/start
[firestore docs]: /docs/firestore/quickstart
[functions docs]: /docs/functions/get-started
[fcm docs]: /docs/cloud-messaging/flutter/client
[storage docs]: /docs/storage/flutter/start
[crashlytics docs]: /docs/crashlytics/get-started?platform=flutter
[ddls docs]: /docs/dynamic-links/flutter/create
[fiam docs]: /docs/in-app-messaging/get-started?platform=flutter
[installations docs]: /docs/projects/manage-installations
[ml docs]: /docs/ml/flutter/use-custom-models
[perfmon docs]: /docs/perf-mon/flutter/get-started
[rtdb docs]: /docs/database/flutter/start
[remote config docs]: /docs/remote-config/get-started?platform=flutter
