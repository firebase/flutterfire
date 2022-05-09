{# This content gets published to the following location:                        #}
{#   https://firebase.google.com/docs/analytics/user-properties?platform=flutter #}

{# TODO(markarndt): Sync all this content up with Analytics content consolidation plan. #}

## Before you begin

Make sure that you've set up your project and can access Analytics as
described in [Get Started with Analytics](get-started).

## Set user properties

You can set Analytics User Properties to describe the users of your app.
You can analyze behaviors of various user segments by applying these
properties as filters to your reports.

Set a user property as follows:

1. Register the property in the [** User Properties ** page](https://console.firebase.google.com/project/_/analytics/userproperty)
   of Analytics in the Firebase console. For more information, see
   [Set and register a user property](//support.google.com/firebase/answer/6317519?ref_topic=6317489#create-property).
1. Add code to set an Analytics User Property with the `setUserProperty()`
   method.

The following example
adds a hypothetical favorite food property, which assigns the value in
`favoriteFood` to the active user:

```dart
await FirebaseAnalytics.instance
  .setUserProperty({
    name: 'favorite_food',
    value: favoriteFood,
  });
```
