{# This content gets published to the following location:                          #}
{#   https://firebase.google.com/docs/perf-mon/custom-code-traces?platform=flutter #}

Performance Monitoring collects _traces_ to help you monitor the performance of your app. A
trace is a report of performance data captured between two points in time in
your app.

You can create your own traces to monitor performance data associated with
specific code in your app. With a **_custom code trace_**, you can measure how
long it takes your app to complete a specific task or a set of tasks, for
example loading a set of images or querying your database.

The default metric for a custom code trace is its "duration" (the time between
the starting and stopping points of the trace), but you can add
**_custom metrics_**, as well.

In your code, you define the beginning and the end of a custom code trace using
the APIs provided by the Performance Monitoring SDK.

Custom code traces can be started anytime after they've been created, and they
are thread safe.

Since the default metric collected for these traces is "duration", they are
sometimes called "Duration traces".

You can view data from these traces in the _Custom traces_ subtab of the traces
table, which is at the bottom of the _Performance_ dashboard (learn more about
[using the console](#monitor-in-console) later on this page).

Note: Starting and stopping traces too rapidly can be resource intensive, so
you should avoid creating custom code traces at high frequencies (for example,
once per frame in games).

## Default attributes, custom attributes, and custom metrics {:#attributes-and-metrics}

For custom code traces, Performance Monitoring automatically logs
[**_default attributes_**](/docs/perf-mon/attributes)
(common metadata like app version, country, device, etc.)
so that you can filter the data for the trace in the Firebase console. You
can also add and monitor [**_custom attributes_**](#create-custom-attributes)
(such as, game level or user properties).

You can further configure a custom code trace to record
[**_custom metrics_**](#add-custom-metrics) for performance-related events that
occur within the trace's scope. For example, you can create a custom metric for
the number of cache hits and misses or the number of times that the UI becomes
unresponsive for a noticeable period of time.

Custom attributes and custom metrics display in the Firebase console
alongside the default attributes and default metric for the trace.

<aside class="objective">An <em>attribute</em> is a string value that helps
  you filter and segment data in the console. A <em>metric</em> is a numeric
  value that can be charted and measured over time.</aside>


##  Add custom code traces {:#add-custom-code-traces}

Use the Performance Monitoring Trace API 
to add custom code traces to monitor specific application code.

Note the following:

* An app can have multiple custom code traces.
* More than one custom code trace can run at the same time.
* Names for custom code traces must meet the following requirements:
  no leading or trailing whitespace, no leading underscore (`_`) character,
  and max length is 100 characters.
* Custom code traces support adding [custom metrics](#add-custom-metrics) and
  [custom attributes](#create-custom-attributes).

To start and stop a custom code trace, wrap the code that you want to trace with
code similar to the following:

```dart
Trace customTrace = FirebasePerformance.instance.newTrace('custom-trace');
await customTrace.start();

// Code you want to trace

await customTrace.stop();
```

## Add custom metrics to custom code traces {:#add-custom-metrics}

Use the Performance Monitoring Trace API
to add custom metrics to custom code traces.

Note the following:

* Names for custom metrics must meet the following requirements:
  no leading or trailing whitespace, no leading underscore (`_`) character,
  and max length is 100 characters.
* Each custom code trace can record up to 32 metrics (including the default
  _Duration_ metric).

To add a custom metric, add a line of code similar to the following each time
that the event occurs. For example, this custom metric counts
performance- related events that occur in your app, such as cache hits or
retries.

```dart
Trace customTrace = FirebasePerformance.instance.newTrace("custom-trace");
await customTrace.start();

// Code you want to trace

customTrace.incrementMetric("metric-name", 1);

// More code

await customTrace.stop();
```


## Create custom attributes for custom code traces {:#create-custom-attributes}

To use custom attributes, add code to your app that defines the attribute and
associates it with a specific custom code trace. You can set the custom
attribute anytime between when the trace starts and when the trace stops.

Note the following:

* Names for custom attributes must meet the following requirements:
  no leading or trailing whitespace, no leading underscore (`_`) character,
  and max length is 32 characters.

* Each custom code trace can record up to 5 custom attributes.

* You shouldn't use custom attributes that contain information that personally
  identifies an individual to Google.

  {{'<aside>'}}
  **Collecting user data**

  Performance Monitoring does not itself collect any
  personally identifiable information (PII), such as names, email addresses, or
  phone numbers. Developers can collect additional data using Performance
  Monitoring by creating custom attributes on custom code traces. Such data
  collected through Performance Monitoring should not contain information that
  personally identifies an individual to Google.

  Here's an example of a log message that does not contain personally
  identifiable information:

  ```dart
  customTrace.putAttribute("experiment", "A");  // OK
  ```

  Here's an example that does contain personally identifiable information (do
  not use this type of custom attribute in your app):

  ```dart
  customTrace.putAttribute(("email", user.getEmailAddress());  // Don't do this!
  ```

  Data that exposes any personally identifiable information is subject to
  deletion without notice.

  {{'</aside>'}}

```dart
Trace trace = FirebasePerformance.instance.newTrace("test_trace");

// Update scenario.
trace.putAttribute("experiment", "A");

// Reading scenario.
String? experimentValue = trace.getAttribute("experiment");

// Delete scenario.
trace.removeAttribute("experiment");

// Read attributes.
Map<String, String> traceAttributes = trace.getAttributes();
```

## Track, view, and filter performance data {:#monitor-in-console}

### Track specific metrics in your dashboard {:#track-in-dashboard}

To learn how your key metrics are trending, add them to your metrics board at
the top of the _Performance_ dashboard. You can quickly identify regressions by
seeing week-over-week changes or verify that recent changes in your code are
improving performance.

To add a metric to your metrics board, go to the [_Performance_ dashboard](https://console.firebase.google.com/project/_/performance)
in the Firebase console, then click the _Dashboard_ tab. Click an empty metric
card, then select an existing metric to add to your board. Click the vertical
ellipsis (**&#8942;**) on a populated metric card for more options, like to
replace or remove a metric.

The metrics board shows collected metric data over time, both in graphical form
and as a numerical percentage change.

Learn more about [using the dashboard](/docs/perf-mon/console).


### View traces and their data {:#view-traces-and-data}

To view your traces, go to the [_Performance_ dashboard](https://console.firebase.google.com/project/_/performance)
in the Firebase console, scroll down to the traces table, then click the
appropriate subtab. The table displays some top metrics for each trace, and you
can even sort the list by the percentage change for a specific metric.

If you click a trace name in the traces table, you can then click throug
various screens to explore the trace and drill down into metrics of interest.
On most pages, you can use the **Filter** button (top-left of the screen) to
filter the data by attribute, for example:

- Filter by _App version_ to view data about a past release or your latest
  release
- Filter by _Device_ to learn how older devices handle your app
- Filter by _Country_ to make sure your database location isn't affecting a
  specific region

Learn more about [viewing data for your traces](/docs/perf-mon/console#view-traces-and-data).


## Next Steps

* Learn more about
  [using attributes](/docs/perf-mon/attributes) to examine performance data.

* Learn more about how to
  [track performance issues](/docs/perf-mon/issue-management) in the
  Firebase console.

* [Set up alerts](/docs/perf-mon/alerts) for code changes that are degrading
  the performance of your app. For example, you can configure an email alert for
  your team if the _duration_ of a specific custom code trace exceeds a
  threshold that you set.
