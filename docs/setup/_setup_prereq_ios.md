{# This content gets published to the following location: #}
{#   https://firebase.google.com/docs/flutter/setup       #}

* Install your preferred [editor or IDE](//flutter.io/get-started/editor/).

* Set up a physical Apple device or use a simulator to run your app.

{# Google-internal file; not on GitHub. #}
<<../../../_internal/includes/docs/guides/_setup-ios_prereq_want-to-use-fcm.md>>

* Make sure that your Flutter app targets the following platform versions or
  later:
  * iOS {{min_ios_os_version}}
  * macOS {{min_mac_os_version}}

* [Install Flutter](//flutter.io/get-started/install/) for your specific
  operating system, including the following:

    * Flutter SDK
    * Supporting libraries
    * Platform-specific software and SDKs

* [Sign into Firebase]({{name_appmanagerURL}}){: .external} using your Google
  account.

If you don't already have a Flutter app, you can complete the [Get
Started: Test Drive](//flutter.io/get-started/test-drive/#androidstudio) to
create a new Flutter app using your preferred editor or IDE.

Note: If you're targeting macOS or macOS Catalyst, you must add the [Keychain Sharing capability](https://firebase.google.com/docs/ios/troubleshooting-faq#macos-keychain-sharing) to your target. In Xcode, navigate to your target's *Signing & Capabilities* tab, and then click **+ Capabilities** to add a new capability.
