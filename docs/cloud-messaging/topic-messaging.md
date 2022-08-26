Project: /docs/cloud-messaging/_project.yaml
Book: /docs/_book.yaml
page_type: guide

{% include "_shared/apis/console/_local_variables.html" %}
{% include "_local_variables.html" %}
{% include "docs/cloud-messaging/_local_variables.html" %}
{% include "docs/android/_local_variables.html" %}

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Topic messaging on Flutter

Based on the publish/subscribe model, FCM topic messaging allows you to send a message
to multiple devices that have opted in to a particular topic.  You compose topic messages as
needed, and FCM handles routing and delivering the message reliably to the right
devices.

For example, users of a local tide
forecasting app could opt in to a "tidal currents alerts" topic and receive
notifications of optimal saltwater fishing conditions in specified areas. Users of a sports app
could subscribe to automatic updates in live game scores for their favorite
teams.

Some things to keep in mind about topics:

- Topic messaging is best suited for content such as weather, or other publicly
  available information.

- Topic messages are **optimized for throughput rather than latency**. For fast,
  secure delivery to single devices or small groups of devices,
  [target messages to registration tokens](/docs/cloud-messaging/send-message#send_messages_to_specific_devices),
  not topics.

- If you need to send messages to multiple devices _per user_, consider
  [device group messaging](/docs/cloud-messaging/send-message#send_messages_to_device_groups)
  for those use cases.

- Topic messaging supports unlimited subscriptions for each topic. However, FCM
  enforces limits in these areas:

  - One app instance can be subscribed to no more than 2000 topics.
  - If you are using [batch import](https://developers.google.com/instance-id/reference/server#manage_relationship_maps_for_multiple_app_instances)
    to subscribe app instances, each request is limited to 1000 app instances.
  - The frequency of new subscriptions is rate-limited per project. If you send
    too many subscription requests in a short period of time, FCM servers will
    respond with a `429 RESOURCE_EXHAUSTED` ("quota exceeded") response. Retry
    with exponential backoff.


## Subscribe the client app to a topic

Client apps can subscribe to any existing topic, or they can create a new
topic. When a client app subscribes to a new topic name (one that does
not already exist for your Firebase project), a new topic of that name is
created in FCM and any client can subsequently subscribe to it.

To subscribe to a topic, call `subscribeToTopic()` with the topic name. This method
returns a `Future`, which resolves when the subscription succeeded:

```dart
await FirebaseMessaging.instance.subscribeToTopic("topic");
```

To unsubscribe, call `unsubscribeFromTopic()` with the topic name.


## Next steps

* Learn how to [send topic messages](/docs/cloud-messaging/send-message#send-messages-to-topics).
* Learn how to [Manage topic subscriptions on the server](/docs/cloud-messaging/manage-topics).
* Learn more about the other way to send to multiple devices &mdash;
  [device group messaging](/docs/cloud-messaging/send-message#send-messages-to-multiple-devices).
