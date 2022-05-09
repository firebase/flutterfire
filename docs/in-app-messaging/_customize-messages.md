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
