## Firebase Crashlytics for Flutter EAP

This is a preview release adding support for Firebase Crashlytics on demand reporting in Flutter. This will allow you to 
report fatal errors to the Firebase Crashlytics backend without the need to restart your application.

### Installation

To get started, add the preview version of the `firebase_crashlytics` Flutter plugin to your projects `pubspec.yaml` dependencies:

```yaml
# ...
dependencies:
  firebase_crashlytics:
    git: 
      url: https://github.com/FirebaseExtended/flutterfire.git
      ref: crashlytics-eap
      path: packages/firebase_crashlytics/firebase_crashlytics
# ...
```

#### Android

No additional steps are required for Android.

#### iOS/macOS

For iOS and macOS the preview iOS SDK needs adding to your `{ios/macos}/Podfile`.

You can add this by referencing the `FirebaseCrashlytics` pod from git inside your `'Runner'` target in your Podfile:

```ruby
# ...
target 'Runner' do
  # Add this line:
  pod 'FirebaseCrashlytics', :git => 'https://github.com/firebase/firebase-ios-sdk.git', :branch => 'flutter-fatal'
  # ...
end
# ...
```

Since Flutter projects usually generate the Podfile for you, you may need to add it to `git` so your changes are preserved.
