# firebase_performance_example

Demonstrates how to use the firebase_performance plugin.

## Getting Started

You can build and run the app directly on emulators. To view the performance data in your own Firebase Performance console, follow the instructions below.

### Android

1. Follow the [instructions](https://firebase.google.com/docs/android/setup#create-firebase-project) to create your Firebase project and register an Android app.

1. Download `google-services.json` and replace the existing one in `android/app/` with yours. 

1. Gradle files already have the correct Firebase configuration so no need to change them. Remove the exisitng build files (`build/`) so that your own `google-services.json` will not be overriden,  and then run the app on an Android emulator.

1. In a few minutes you should see data show up in your [Firebase Performance console](https://firebase.corp.google.com/project/_/performance). Click different buttons in the app to generate more data.

### iOS

1. Follow the [instructions](https://firebase.google.com/docs/ios/setup#create-firebase-project) to create your Firebase project and register an iOS app.

1. Download `GoogleService-Info.plist`, and [install it via Xcode](https://firebase.flutter.dev/docs/installation/ios#installing-your-firebase-configuration-file). Make sure you replace the existing one in `ios/Runner` with yours.

1. (Optional) [Enable logging in Xcode](https://firebase.google.com/docs/perf-mon/get-started-ios).

1. Remove the exisitng build files (`build/`) so that your own `GoogleService-Info.plist` will not be overriden,  and then run the app on an Android emulator.

1. In a few minutes you should see data show up in your [Firebase Performance console](https://firebase.corp.google.com/project/_/performance). Click different buttons in the app to generate more data.