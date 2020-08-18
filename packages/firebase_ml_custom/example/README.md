# Example of Firebase Machine Learning Custom
Demonstrates how to use the firebase_ml_custom plugin.

## Usage
In order to run this example app you first need to **upload a tflite model to the Firebase console.**
This app uses `mobilenet_v1_1.0_224.tflite` label recognition model, which you can find in the `assets` folder.
##### How to host this model on Firebase:
1. In the `Machine Learning` section of the Firebase console, click the `Custom` tab.
2. Click `Add model`.
3. Specify a name that will be used to identify your model in your Firebase project, `mobilenet_v1_1_0_224` for this example app. Then upload the TensorFlow Lite model file.

Remember to add your app to the your Firebase project and replace `google-services.json` and `GoogleService-Info.plist` with those from the project with the uploaded model. When you add this app to your Firebase project specify:
- `io.flutter.plugins.firebasemlcustomexample` as Android package name and
- `io.flutter.plugins.firebaseMlCustomExample` as IOS bundle ID.

This example uses the *image_picker* plugin to get images from the device gallery. If using an iOS device you will have to configure your project with the correct permissions seen under iOS configuration [here](https://pub.dev/packages/image_picker).

The example also uses the *tflite* plugin to perform inference. If using an Android device you may need to modify your `android/app/build.gradle` file as specified [here](https://pub.dev/packages/tflite).

### Common issues with installation
1. If your build breaks due to flutter package related issues, run `flutter upgrade`.
2. If you experience TFLite package related issue on IOS, and the issue states that some reader file is not found, check [this](https://github.com/shaqian/flutter_tflite/issues/139) github issue and its solution.
3. If you run the app on IOS, and error is the following: `FLTModelManager.m:78:7: error: no visible @interface for 'FIRModelManager' declares the selector 'getLatestModelFilePath:completion:'`,
it means your Podfile.lock didn't pick up correct dependencies. Try cleaning pod cache and installing pods again.

## Getting Started
For help getting started with Flutter, view our online
[documentation.](https://flutter.io/)
