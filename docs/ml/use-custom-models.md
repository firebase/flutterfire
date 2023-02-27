Project: /docs/_project.yaml
Book: /docs/_book.yaml

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Use a custom TensorFlow Lite model with Flutter

If your app uses custom
[TensorFlow Lite](https://www.tensorflow.org/lite/){:.external} models, you can
use Firebase ML to deploy your models. By deploying models with Firebase, you
can reduce the initial download size of your app and update your app's ML models
without releasing a new version of your app. And, with Remote Config and A/B
Testing, you can dynamically serve different models to different sets of users.

## TensorFlow Lite models

TensorFlow Lite models are ML models that are optimized to run on mobile
devices. To get a TensorFlow Lite model:

- Use a pre-built model, such as one of the [official TensorFlow Lite models](https://www.tensorflow.org/lite/models){:.external}
- [Convert a TensorFlow model, Keras model, or concrete function to TensorFlow Lite.](https://www.tensorflow.org/lite/convert){:.external}

Note that in the absence of a maintained TensorFlow Lite library for Dart, you
will need to integrate with the native TensorFlow Lite library for your
platforms. This integration is not documented here.

## Before you begin

1.  [Install and initialize the Firebase SDKs for Flutter](/docs/flutter/setup)
    if you haven't already done so.

1.  From the root directory of your Flutter project, run the following
    command to install the ML model downloader plugin:

    ```bash
    flutter pub add firebase_ml_model_downloader
    ```

1.  Rebuild your project:

    ```bash
    flutter run
    ```

## 1. Deploy your model {:#deploy}

Deploy your custom TensorFlow models using either the Firebase console or
the Firebase Admin Python and Node.js SDKs. See
[Deploy and manage custom models](/docs/ml/manage-hosted-models).

After you add a custom model to your Firebase project, you can reference the
model in your apps using the name you specified. At any time, you can deploy a
new TensorFlow Lite model and download the new model onto users' devices by
calling `getModel()` (see below).

## 2. Download the model to the device and initialize a TensorFlow Lite interpreter

To use your TensorFlow Lite model in your app, first use the model downloader
to download the latest version of the model to the device. Then, instantiate a
TensorFlow Lite interpreter with the model.

To start the model download, call the model downloader's `getModel()` method,
specifying the name you assigned the model when you uploaded it, whether you
want to always download the latest model, and the conditions under which you
want to allow downloading.

You can choose from three download behaviors:

| Download type                    | Description
|----------------------------------|--------------------------------------------
| `localModel`                     | Get the local model from the device.
:                                  : If there is no local model available, this
:                                  : behaves like `latestModel`. Use this
:                                  : download type if you are not interested in
:                                  : checking for model updates. For example,
:                                  : you're using Remote Config to retrieve
:                                  : model names and you always upload models
:                                  : under new names (recommended).
| `localModelUpdateInBackground`   | Get the local model from the device and
:                                  : start updating the model in the background.
:                                  : If there is no local model available, this
:                                  : behaves like `latestModel`.
| `latestModel`                    | Get the latest model. If the local model is
:                                  : the latest version, returns the local
:                                  : model. Otherwise, download the latest
:                                  : model. This behavior will block until the
:                                  : latest version is downloaded (not
:                                  : recommended). Use this behavior only in
:                                  : cases where you explicitly need the latest
:                                  : version.

You should disable model-related functionality&mdash;for example, grey-out or
hide part of your UI&mdash;until you confirm the model has been downloaded.

```dart
FirebaseModelDownloader.instance
    .getModel(
        "yourModelName",
        FirebaseModelDownloadType.localModel,
        FirebaseModelDownloadConditions(
          iosAllowsCellularAccess: true,
          iosAllowsBackgroundDownloading: false,
          androidChargingRequired: false,
          androidWifiRequired: false,
          androidDeviceIdleRequired: false,
        )
    )
    .then((customModel) {
      // Download complete. Depending on your app, you could enable the ML
      // feature, or switch from the local model to the remote model, etc.

      // The CustomModel object contains the local path of the model file,
      // which you can use to instantiate a TensorFlow Lite interpreter.
      final localModelPath = customModel.file;

      // ...
    });
```

Many apps start the download task in their initialization code, but you can do
so at any point before you need to use the model.


## 3. Perform inference on input data

Now that you have your model file on the device you can use it with the
TensorFlow Lite interpreter to perform inference. In the absence of a maintained
TensorFlow Lite library for Dart, you will need to integrate with the
[native TensorFlow Lite libraries](https://www.tensorflow.org/lite){:.external}
for iOS and Android.


## Appendix: Model security {:#model_security}

Regardless of how you make your TensorFlow Lite models available to
Firebase ML, Firebase ML stores them in the standard serialized protobuf format in
local storage.

In theory, this means that anybody can copy your model. However,
in practice, most models are so application-specific and obfuscated by
optimizations that the risk is similar to that of competitors disassembling and
reusing your code. Nevertheless, you should be aware of this risk before you use
a custom model in your app.
