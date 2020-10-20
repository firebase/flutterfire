# firebase_storage_web

The web implementation of `firebase_storage`.

## Getting Started

To get started with Firebase Storage, please [see the documentation](https://firebase.flutter.dev/docs/storage/overview)
available at [https://firebase.flutter.dev](https://firebase.flutter.dev)

Once installed, Firebase Storage needs to be configured for Web Installation.  Please [see the documentation](https://firebase.flutter.dev/docs/storage/overview#3-web-only-add-the-sdk) on Web Installation

To learn more about Firebase Storage, please visit the [Firebase website](https://firebase.google.com/products/storage)

## Downloading files with `getData()`

When using `Reference::getData()` in the web platform, your bucket must have the correct CORS configuration, or the security mechanisms in the browser will *not* let you access the downloaded data, with exceptions similar to:

```
Access to XMLHttpRequest at 'https://firebasestorage.googleapis.com/v0/b/...example.txt?alt=media&token=1234-4321-1234-4321-12341234' from origin 'http://your-web-app.domain.com:PORT' has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present on the requested resource.
```

```
browser_client.dart:87 GET https://firebasestorage.googleapis.com/v0/b/...example.txt?alt=media&token=1234-4321-1234-4321-12341234 net::ERR_FAILED
```

or

```
Error: XMLHttpRequest error.
    dart-sdk/lib/_internal/js_dev_runtime/patch/core_patch.dart 894:28                get current
packages/http/src/browser_client.dart 84:22                                       <fn>
```

You need to enable CORS response headers in your Google Cloud Storage Bucket, as described in the following document:

* Firebase > Docs > Guides > [Download Files on Web](https://firebase.google.com/docs/storage/web/download-files).

In the `example` app, ensure there's a `cors.json` file:

```
firebase_storage/example$ cat cors.json
[
  {
    "origin": ["*"],
    "method": ["GET"],
    "maxAgeSeconds": 3600
  }
]
```

And then, with `gsutil`:

```
firebase_storage/example$ gsutil cors set cors.json gs://my-example-bucket.appspot.com
Setting CORS on gs://my-example-bucket.appspot.com/...
```

For much, much more information about CORS in Google Cloud Platform, see:

* Storage products > Cloud Storage > Documentation > [Configuring cross-origin resource sharing (CORS)](https://cloud.google.com/storage/docs/configuring-cors)
