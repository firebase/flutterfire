{# This content gets published to the following location:               #}
{#   https://firebase.google.com/docs/analytics/events?platform=flutter #}

Analytics automatically logs some
[events](https://support.google.com/firebase/answer/6317485) for you; you don't
need to add any code to receive them. If your app needs to collect additional
data, you can log up to 500 different Analytics Event *types* in your app.
There is no limit on the total volume of events your app logs. Note that event
names are case-sensitive and that logging two events whose names differ only in
case will result in two distinct events.

## Before you begin

Make sure that you've set up your project and can access Analytics as
described in [Get Started with Analytics](get-started).

## Log events

After you have created a `FirebaseAnalytics` instance, you can use it to log
events with the library's `log`- methods.

### Predefined events

To help you get started, the Analytics SDK defines a number of
recommended events that are common among different types of apps, including
retail and ecommerce, travel, and gaming apps. To learn more
[about these events](https://support.google.com/analytics/answer/9322688)
and when to use them, browse the
[Events and properties](https://support.google.com/firebase/topic/6317484)
articles in the Firebase Help Center.

Note: To get the maximum detail in reports, log the recommended events that make
sense for your app and their prescribed parameters. This also ensures that you
benefit from the latest Google Analytics features as
they become available.


You can find the log methods for the recommended event types in the
[API reference](https://pub.dev/documentation/firebase_analytics/latest/firebase_analytics/FirebaseAnalytics-class.html).

The following example demonstrates how to log a `select_content` event:

```dart
await FirebaseAnalytics.instance.logSelectContent(
    contentType: "image",
    itemId: itemId,
);
```

Alternatively, you can log the same event using `logEvent()`:

```dart
await FirebaseAnalytics.instance.logEvent(
    name: "select_content",
    parameters: {
        "content_type": "image",
        "item_id": itemId,
    },
);
```

This can be useful if you want to specify additional parameters other than the
prescribed (required) parameters. You can add the following parameters
to any event:

* Custom parameters: Custom parameters can be used as
  [dimensions or metrics](https://support.google.com/analytics/answer/10075209)
  in [Analytics reports](https://support.google.com/analytics/answer/9212670).
  You can use custom dimensions for non-numerical event parameter data and
  custom metrics for any parameter data better represented numerically. Once
  you've logged a custom parameter using the SDK, register the dimension or
  metric to ensure those custom parameters appear in Analytics
  reports. Do this via: *Analytics > Events > Manage Custom Definitions >
  Create Custom Dimensions*

  Custom parameters can be used in
  [audience](https://support.google.com/firebase/answer/6317509)
  definitions that may be applied to every report.
  Custom parameters are also included in data
  [exported to BigQuery](https://support.google.com/firebase/answer/7030014)
  if your app is linked to a BigQuery project. Find sample queries and much more
  at [Google Analytics 4 BigQuery Export](https://developers.google.com/analytics/bigquery).

* `value` parameter: a general purpose parameter
  that is useful for accumulating a key metric that pertains to an
  event. Examples include revenue, distance, time, and points.
* Parameter names can be up to 40 characters long and must start with an alphabetic
  character and contain only alphanumeric characters and underscores. String and num
  types are supported. String parameter values can be up to 100 characters long.
  The "firebase_", "google_" and "ga_" prefixes are reserved and should not be used for parameter names.

### Custom events

If your application has specific needs not covered by a recommended
event type, you can log your own custom events as shown in this example:

```dart
await FirebaseAnalytics.instance.logEvent(
    name: "share_image",
    parameters: {
        "image_name": name,
        "full_text": text,
    },
);
```

## Set default event parameters

You can log parameters across events using `setDefaultEventParameters()`.
Default parameters are associated with all future events that are logged.

As with custom parameters, register the default event parameters to ensure they
appear in Analytics reports.

Valid parameter values are String and num. Setting a key's value to null will
clear that parameter. Passing in a null value will clear all parameters.

```dart
// Not supported on web
await FirebaseAnalytics.instance
  .setDefaultEventParameters({
    version: '1.2.3'
  });
```

If a parameter is specificed in the `logEvent()` or `log`-
method, that value is used instead of the default.

To clear a default parameter, call the `setDefaultEventParameters()`
method with the parameter set to `null`.
