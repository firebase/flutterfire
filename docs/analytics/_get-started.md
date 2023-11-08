{# This content gets published to the following location:                    #}
{#   https://firebase.google.com/docs/analytics/get-started?platform=flutter #}

Google Analytics collects usage and behavior data for your app. The SDK
logs two primary types of information:

* **Events:** What is happening in your app, such as user actions, system
  events, or errors.
* **User properties:** Attributes you define to describe segments of your
  user base, such as language preference or geographic location.

Analytics automatically logs some
[events](https://support.google.com/analytics/answer/9234069) and
[user properties](https://support.google.com/analytics/answer/9268042);
you don't need to add any code to enable them.

## Before you begin

1. [Install `firebase_core`](/docs/flutter/setup) and add the initialization code
  to your app if you haven't already.
1. Add your app to your Firebase project in the
  [Firebase console](https://console.firebase.google.com).

## Add the Analytics SDK to your app {:#add-sdk}

1.  From the root of your Flutter project, run the following command to install the plugin:

    ```bash {5}
    flutter pub add firebase_analytics
    ```

1.  Once complete, rebuild your Flutter application:

    ```bash
    flutter run
    ```

1.  Once installed, you can access the `firebase_analytics`
    plugin by importing it in your Dart code:

    ```dart
    import 'package:firebase_analytics/firebase_analytics.dart';
    ```

1.  Create a new Firebase Analytics instance by accessing the
    `instance` property on
    `FirebaseAnalytics`:

    ```dart
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    ```


## Start logging events

After you have created a `FirebaseAnalytics` instance, you can begin to log
events with the library's `log`- methods.

Certain events are
[recommended for all apps](https://support.google.com/analytics/answer/9267735);
others are recommended for specific business types or verticals. You should send
recommended events along with their prescribed parameters, to ensure maximum
available detail in your reports and to benefit from future features and
integrations as they become available. This section demonstrates logging a
predefined event, for more information on logging events, see
[Log events](events).

The following code logs a checkout event:

```dart
await FirebaseAnalytics.instance
  .logBeginCheckout(
    value: 10.0,
    currency: 'USD',
    items: [
      AnalyticsEventItem(
        itemName: 'Socks',
        itemId: 'xjw73ndnw',
        price: '10.0'
      ),
    ],
    coupon: '10PERCENTOFF'
  );
```

## Next steps

* Use the [DebugView](/docs/analytics/debugview) to verify your events.
* Explore your data in the [Firebase console](https://console.firebase.google.com/project/_/analytics/).
* Explore the guides on [events](events) and
  [user properties](user-properties).
* Learn how to export your data to [BigQuery](https://support.google.com/firebase/answer/7030014).
