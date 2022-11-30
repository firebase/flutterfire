{# This content gets published to the following location:                        #}
{#   https://firebase.google.com/docs/analytics/user-properties?platform=flutter #}

{# TODO(markarndt): Sync all this content up with Analytics content
consolidation plan. #}

## Before you begin

Make sure that you've set up your project and can access {{analytics}} as
described in [Get Started with {{analytics}}](get-started).

## Set user properties

You can set {{ analytics }} user properties to describe the users of your app.
You can make use of user properties by creating custom definitions, then using
them to apply comparisons in your reports or as audience evaluation criteria.

To set a user property, follow these steps:

1. Create a custom definition for the user property in the
  [**Custom Definitions** page](https://console.firebase.google.com/project/_/analytics/userproperty){: .external}
  of _{{analytics}}_ in the {{name_appmanager}}. For more information, see
  [Custom dimensions and metrics](//support.google.com/firebase/answer/6317519).
1. Set a user property in your app with the `setUserProperty()` method.

The following example adds a hypothetical favorite food property, which
assigns the value in `favoriteFood` to the active user:

```dart
await FirebaseAnalytics.instance
  .setUserProperty({
    name: 'favorite_food',
    value: favoriteFood,
  });
```
