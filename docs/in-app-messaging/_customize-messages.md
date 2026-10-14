{# This content gets published to the following location:                                   #}
{#   https://firebase.google.com/docs/in-app-messaging/customize-messaging?platform=flutter #}

Firebase In-App Messaging provides a useful set of preconfigured behaviors and
message types with a default look and feel, but in some cases you may want to
extend behaviors and message content. In-App Messaging allows you to add actions
to messages and customize message look and feel.

## Add an action to your message

With actions you can use your in-app messages to direct users to a
website or a specific screen in your app.

### Implement a deep link handler

Firebase In-App Messaging uses link handlers to process actions. The SDK is
able to use a number of handlers, so if your app already has one, Firebase
In-App Messaging can use that without any further setup. If you don't yet have
a handler, you can use [Firebase Dynamic Links](/docs/dynamic-links).

### Add the action to your message using the Firebase console

Once your app has a link handler, you're ready to compose a campaign with
an action. Open the Firebase console to
[In-App Messaging](https://console.firebase.google.com/project/_/inappmessaging),
and start a new campaign or edit an existing campaign. In that campaign, provide
a **Card**, **Button text** and **Button action**, an **Image action**, or a **Banner
action**, where the action is a relevant deep link.

The action's format depends on which message layout you choose. Modals get
action buttons with customizable button text content, text color, and background
color. Images and top banners, on the other hand, become interactive and invoke
the specified action when tapped.

## Render campaigns with Flutter widgets

By default, In-App Messaging draws native templates (banner, modal, card,
image-only). To render campaigns with your own Flutter UI instead, opt in to
custom display, listen for the campaign payload, and report impression, click,
and dismiss back to the SDK:

```dart
FirebaseInAppMessaging.instance.onMessageDisplay.listen((message) async {
  await message.impress();
  // Draw your own widgets using message.title, body, imageUrl, actions, data.
  // The plugin does not open action URLs — your app should.
  await message.click(message.primaryAction ?? message.action!);
  await message.dismiss();
});

await FirebaseInAppMessaging.instance.setCustomDisplayEnabled(true);
```

Until `setCustomDisplayEnabled(true)` is called, native templates keep working.
Listening to `onMessageDisplay` alone does not replace native UI.

If you also listen to `onMessageClicked` / `onMessageImpression`, those
lifecycle streams still fire when your Flutter UI reports click and impress.
