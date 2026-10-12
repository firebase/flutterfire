{# This content gets published to the following location:                             #}
{#   https://firebase.google.com/docs/perf-mon/custom-network-traces?platform=flutter #}

Performance Monitoring collects _traces_ to help you monitor the performance of your app. A
trace is a report of performance data captured between two points in time in
your app.

The
[network request traces automatically collected by Performance Monitoring](/docs/perf-mon/network-traces)
on Android and Apple platforms only include requests made by native code, such
as native SDKs that your app depends on. Requests made from Dart, including
requests made with `dart:io` `HttpClient`, `package:http` with its default
client, or `Image.network`, are not collected automatically. To monitor these
requests, use the Performance Monitoring API to manually instrument
**_custom network request traces_**. Custom network request traces are only
supported for Apple and Android apps.

The default metrics for a custom network request trace are the same as those for
the network request traces automatically collected by Performance Monitoring, specifically
response time, response and request payload size, and success rate. Custom
network request traces do not support adding custom metrics.

In your code, you define the beginning and the end of a custom network request
trace using the APIs provided by the Performance Monitoring SDK.

Custom network request traces appear in the Firebase console alongside the
network requests that Performance Monitoring captures automatically
(in the _Network requests_ subtab of the traces table).


## Add custom network request traces {:#add-custom-network-traces}

Use the Performance Monitoring HttpMetric API
to add custom network request traces to monitor specific network requests.

To manually instrument custom network requests in Performance Monitoring, add code similar
to the following:

```dart
final metric = FirebasePerformance.instance
    .newHttpMetric("https://www.google.com", HttpMethod.Get);

await metric.start();
final response = await http.get(Uri.parse("https://www.google.com/"));
await metric.stop();
```

Custom network request traces also support adding custom attributes
but not custom metrics.


## Next steps

* [Set up alerts](/docs/perf-mon/alerts) for network requests that are degrading
  the performance of your app. For example, you can configure an email alert for
  your team if the _response time_ for a specific URL pattern exceeds a
  threshold that you set.
