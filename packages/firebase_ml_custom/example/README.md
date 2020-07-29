# Example of Firebase Machine Learning Custom
Demonstrates how to use the firebase_ml_custom plugin.

## Usage
In order to run this example app you first need to **upload a tflite model to the Firebase console.**
This app uses `mobilenet_v1_1.0_224.tflite` label recognition model, which you can find in the `assets` folder.
###### How to host this model on Frebase:
1. In the `Machine Learning` section of the Firebase console, click the `Custom` tab.
2. Click `Add model`.
3. Specify a name that will be used to identify your model in your Firebase project, `mobilenet_v1_1_0_224` for this example app. Then upload the TensorFlow Lite model file.

Remember to replace `google-services.json` and `GoogleService-Info.plist` with those from the project with the uploaded model.

This example uses the *image_picker* plugin to get images from the device gallery. If using an iOS device you will have to configure your project with the correct permissions seen under iOS configuration [here](https://pub.dartlang.org/packages/image_picker).

The example also uses the *tflite* plugin to perform inference. If using an Android device you may need to modify your `android/app/build.gradle` file as specified [here](https://pub.dartlang.org/packages/tflite).

## Getting Started
For help getting started with Flutter, view our online
[documentation.](https://flutter.io/)
