{# This content gets published to the following location:                                       #}
{#   https://firebase.google.com/docs/in-app-messaging/modify-message-behavior?platform=flutter #}

With little to no coding effort, Firebase In-App Messaging allows you to create,
configure and target rich user interactions, leveraging
the capabilities of Google Analytics out of the box
to tie messaging events to actual user characteristics, activities, and choices.
With some additional Firebase In-App Messaging SDK integration, you can tailor
the behavior of in-app messages even further, responding when users interact
with messages, triggering message events outside the Analytics
framework, and allowing users to control sharing of their personal data related
to messaging interactions.

## Respond when users interact with in-app messages

With actions you can use your in-app messages to direct users to a
website or a specific screen in your app.

Your code can respond to basic interactions (clicks and dismissals), to
impressions (verified views of your messages), and to display errors logged and
confirmed by the SDK. For example, when your message is composed as a Card
modal, you might want to track and follow-up on which of two URLs the user
clicked on the Card.

To do so, you will have to use the platform-native APIs.
See the documentation for [iOS](/docs/in-app-messaging/modify-message-behavior?platform=ios#respond_when_users_interact_with_in-app_messages)
and [Android](/docs/in-app-messaging/modify-message-behavior?platform=android#respond_when_users_interact_with_in-app_messages).

## Trigger in-app messages programmatically

Firebase In-App Messaging by default allows you to trigger in-app messages with
Google Analytics for Firebase events, with no additional integration. You can
also manually trigger events programmatically with the Firebase In-App Messaging SDK's
programmatic triggers.

In the In-App Messaging campaign composer, create a new campaign or select an
existing campaign, and in the Scheduling step of the composer workflow, note the
event ID of a newly-created or existing messaging event. Once noted, instrument
your app to trigger the event by its ID.

```dart
FirebaseInAppMessaging.instance.triggerEvent("eventName");
```

## Use campaign custom metadata

In your campaigns, you can specify custom data in a series of key/value pairs.
When users interact with messages, this data is available for you to, for example,
display a promo code.

To do so, you will have to use the platform-native APIs.
See the documentation for [iOS](/docs/in-app-messaging/modify-message-behavior?platform=ios#use_campaign_custom_metadata)
and [Android](/docs/in-app-messaging/modify-message-behavior?platform=android#use_campaign_custom_metadata).


## Temporarily disable in-app messages

By default, Firebase In-App Messaging renders messages whenever a triggering
condition is satisfied, regardless of an app's current state. If you'd like to
suppress message displays for any reason, for example to avoid interrupting a
sequence of payment processing screens, you can do that with the SDK's
`setMessagesSuppressed()` method:

```dart
FirebaseInAppMessaging.instance.setMessagesSuppressed(true);
```

Passing `true` to the method prevents Firebase In-App Messaging from displaying
messages, while `false` reenables message display. The SDK turns off message
suppression on app restart. Suppressed messages are ignored by the SDK. Their
trigger conditions must be met again while suppression is off before Firebase
In-App Messaging can display them.

## Enable opt-out message delivery

By default, Firebase In-App Messaging automatically delivers messages to all app users you target
in messaging campaigns. To deliver those messages, the Firebase In-App Messaging SDK uses
installation IDs to identify each user's app. This means
that In-App Messaging has to send client data, linked to the
installation ID, to Firebase servers. If you'd like to give users
more control over the data they send, disable automatic data collection and give
them a chance to approve data sharing.

To do that, you have to disable automatic initialization for Firebase In-App Messaging, and
initialize the service manually for opt-in users:

1.  Turn off automatic initialization.

    **Apple platforms**: Add a new key to your `Info.plist` file:

    - Key: `FirebaseInAppMessagingAutomaticDataCollectionEnabled`
    - Value: `NO`

    **Android**: Add a `meta-data` tag to your `AndroidManifest.xml` file:

    ```xml
    <meta-data
        android:name="firebase_inapp_messaging_auto_data_collection_enabled"
        android:value="false" />
    ```

1.  Initialize Firebase In-App Messaging for selected users manually:

    ```dart
    FirebaseInAppMessaging.instance.setAutomaticDataCollectionEnabled(true);
    ```

    Once you set a data collection preference manually, the value persists
    through app restarts, overriding the value in your `Info.plist` or
    `AndroidManifest.xml`. If you'd like to disable initialization again, for
    example if a user opts out of collection later, pass `false` to the
    `setAutomaticDataCollectionEnabled()` method.
