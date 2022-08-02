Project: /docs/_project.yaml
Book: /docs/_book.yaml

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Receive Firebase Dynamic Links in a Flutter app

To receive the Firebase Dynamic Links that <a href="/docs/dynamic-links/create-links">you created</a>,
you must include the Dynamic Links SDK in your app and call the
`FirebaseDynamicLinks.getDynamicLink()` method when your app loads to
get the data passed in the Dynamic Link.

## Set up Firebase and the Dynamic Links SDK

1.  [Install and initialize the Firebase SDKs for Flutter](/docs/flutter/setup) if you
    haven't already done so.

1.  From the root directory of your Flutter project, run the following
    command to install the Dynamic Links plugin:

    ```
    flutter pub add firebase_dynamic_links
    ```

1.  If you're building an Android app, open the [Project settings](https://console.firebase.google.com/project/_/settings/general/)
    page of the Firebase console and make sure you've specified your SHA-1
    signing key. If you use App Links, also specify your SHA-256 key.

## Platform integration

Complete the following platform integration steps for the platforms you're
building your app for.

### Android

On Android, you must add a new intent filter catch deep links of your domain, since the
Dynamic Link will redirect to your domain if your app is installed. This is required for your app to
receive the Dynamic Link data after it is installed/updated from the Play Store and one taps on
Continue button. In `AndroidManifest.xml`:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data
        android:host="example.com"
        android:scheme="https"/>
</intent-filter>
```

When users open a Dynamic Link with a deep link to the scheme and host you specify, your app will
start the activity with this intent filter to handle the link.

### Apple platforms

1.  [Create an Apple developer account](https://developer.apple.com/programs/enroll/)
    if you don't already have one.

1.  On the [Project settings](https://console.firebase.google.com/project/_/settings/general/)
    page of the Firebase console, ensure that your iOS app is correctly
    configured with your App Store ID and Team ID.

1.  On the Apple Developer site, create a provisioning profile for your app
    with the Associated Domain capability enabled.

1.  In Xcode, do the following:

    1.  Open your app under the **TARGETS** header.

    1.  On the Signing & Capabilities page, ensure your Team is registered, and
        your Provisioning Profile is set.

    1.  On the Signing & Capabilities page, enable **Associated Domains** and
        add the following to the Associated Domains list:

        ```
        applinks:example.page.link
        ```

    1.  On the Info page, add a URL Type to your project. Set the URL Schemes
        field to your app's bundle ID. (The Identifier can be `Bundle ID` or
        whatever you wish.)

    1.  If you have set up a custom domain for your Firebase project, add the
        Dynamic Link URL prefix into your iOS project's `Info.plist` file
        using the `FirebaseDynamicLinksCustomDomains` key.

        ```xml
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
        <key>FirebaseDynamicLinksCustomDomains</key>
        <array>
            <string>https://custom.domain.io/path1</string>
            <string>https://custom.domain.io/path2</string>
        </array>

        ...other settings

        </dict>
        </plist>
        ```

    1.  **Optional:** Disable the Dynamic Links SDK's use of the iOS pasteboard.

        By default, the Dynamic Links SDK uses the pasteboard to improve the
        reliability of post-install deep links. By using the pasteboard, Dynamic
        Links can make sure that when a user opens a Dynamic Link but needs to
        install your app first, the user can go immediately to the original
        linked content when opening the app for the first time after
        installation.

        The downside of this is that use of the pasteboard triggers a
        notification on iOS 14 and later. So, the first time users open your
        app, if the pasteboard contains a Dynamic Link URL, they will see a
        notification that your app accessed the pasteboard, which can cause
        confusion.

        To disable this behavior, edit your Xcode project's `Info.plist` file
        and set the `FirebaseDeepLinkPasteboardRetrievalEnabled` key to `NO`.

        Note: When you disable this feature, the Dynamic Links you receive will have
        a `matchType` of `weak` at best. Adjust your app's logic accordingly.


## Handle deep links {:#handle_deep_links}

To handle a Dynamic Link in your application, two scenarios require implementing.

### Terminated State

If the application is terminated, the `FirebaseDynamicLinks.getInitialLink`
method allows you to retrieve the Dynamic Link that opened the application.

This is an asynchronous request, so it makes sense to handle a link before rendering application logic, such as
a navigator. For example, you could handle this in the `main` function:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseConfig.platformOptions);

  // Get any initial links
  final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();

  runApp(MyApp(initialLink));
}
```

Within your application logic, you can then check whether a link was handled and perform an action, for example:

```dart
if (initialLink != null) {
  final Uri deepLink = initialLink.link;
  // Example of using the dynamic link to push the user to a different screen
  Navigator.pushNamed(context, deepLink.path);
}
```

Alternatively, if you wish to identify if an exact Dynamic Link was used to open the application, pass it to
the `getDynamicLink` method instead:

```dart
String link = 'https://dynamic-link-domain/ke2Qa';

final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getDynamicLink(Uri.parse(link));
```

### Background / Foreground State

Whilst the application is open, or in the background, you may listen to Dynamic Links events using a stream handler. The `FirebaseDynamicLinks.onLink`
getter returns a `Stream` containing a `PendingDynamicLinkData`:

```dart
FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
  Navigator.pushNamed(context, dynamicLinkData.link.path);
}).onError((error) {
  // Handle errors
});
```

### Testing A Dynamic Link On iOS Platform

To test a dynamic link on iOS, it is required that you use an actual device. You will also need to run the app in release mode (i.e. `flutter run --release`.),
if testing a dynamic link from a terminated (i.e. app has been swiped closed.) app state.
