{# This content gets published to the following location:                              #}
{#   https://firebase.google.com/docs/crashlytics/start-using-analytics?platform=flutter #}

1.  Make sure that {{firebase_analytics}} is enabled in your Firebase project:
    Go to <nobr><span class="material-icons">settings</span> > _Project settings_</nobr> > _Integrations_ tab,
    then follow the on-screen instructions for {{firebase_analytics}}.

1.  From the root of your Flutter project, run the following command to install
    the {{analytics}} Flutter plugin:

    <pre class="devsite-terminal devsite-click-to-copy"
         data-terminal-prefix="your-flutter-proj$ ">flutter pub add firebase_analytics
    </pre>

1.  Make sure that your Flutter app's Firebase configuration is up-to-date by
    running the following command from the root directory of your Flutter
    project:

    <pre class="devsite-terminal devsite-click-to-copy"
         data-terminal-prefix="your-flutter-proj$ ">flutterfire configure
    </pre>

1.  Once complete, rebuild your Flutter application:

    <pre class="devsite-terminal devsite-click-to-copy"
         data-terminal-prefix="your-flutter-proj$ ">flutter run
    </pre>

Your Flutter project is now set up to use {{firebase_analytics}}.
