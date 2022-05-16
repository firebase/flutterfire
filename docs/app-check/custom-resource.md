Project: /docs/_project.yaml
Book: /docs/_book.yaml

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Protect non-Firebase resources with App Check

You can protect your app's non-Firebase resources, such as self-hosted backends,
with App Check. To do so, you will need to do both of the following:

- Modify your app client to send an App Check token along with each request
  to your backend, as described on this page.
- Modify your backend to require a valid App Check token with every request,
  as described in [Verify App Check tokens from a custom backend](/docs/app-check/custom-resource-backend).

## Before you begin

Add App Check to your app, using the [default providers](default-providers).

## Send App Check tokens with backend requests

To ensure your backend requests include a valid, unexpired, App Check token,
precede each request with a call to `getToken()`. The App Check library
will refresh the token if necessary.

Once you have a valid token, send it along with the request to your backend. The
specifics of how you accomplish this are up to you, but _don't send
App Check tokens as part of URLs_, including in query parameters, as this
makes them vulnerable to accidental leakage and interception. The recommended
approach is to send the token in a custom HTTP header.

For example:

```dart
void callApiExample() async {
    final appCheckToken = await FirebaseAppCheck.instance.getToken();
    if (appCheckToken != null) {
        final response = await http.get(
            Uri.parse("https://yourbackend.example.com/yourExampleEndpoint"),
            headers: {"X-Firebase-AppCheck": appCheckToken},
        );
    } else {
        // Error: couldn't get an App Check token.
    }
}
```
