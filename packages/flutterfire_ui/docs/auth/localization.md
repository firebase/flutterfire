# Localization

FlutterFire UI for Auth supports localization, so every single text label can be customized.

If your app supports only a single language, and you want to override labels – you will need to provide a custom class that implements [`DefaultLocalizations`](https://pub.dev/documentation/flutterfire_ui/latest/i10n/DefaultLocalizations-class.html),
for example:

```dart
import 'package:flutterfire_ui/i10n.dart';

class LabelOverrides extends DefaultLocalizations {
  const LabelOverrides();

  @override
  String get emailInputLabel => 'Enter your email';

  @override
  String get passwordInputLabel => 'Enter your password';
}
```

Once created, pass the instance of `LabelOverrides` to the `localizationsDelegates` list in your `MaterialApp`/`CupertinoApp`:

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        // Creates an instance of FirebaseUILocalizationDelegate with overridden labels
        FlutterFireUILocalizations.withDefaultOverrides(const LabelOverrides()),
        
        // Delegates below take care of built-in flutter widgets
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,

        // This delegate is required to provide the labels that are not overridden by LabelOverrides
        FlutterFireUILocalizations.delegate,
      ],
      // ...
    );
  }
}
```

If you need to support multiple languages – follow the [official Flutter localization guide](https://docs.flutter.dev/development/accessibility-and-localization/internationalization#an-alternative-class-for-the-apps-localized-resources) 
and make sure that your custom delegate extends `LocalizationsDelegate<FlutterFireUILocalizations>`.

> Note: check out [API reference](https://pub.dev/documentation/flutterfire_ui/latest/index.html) to learn what labels are used by specific widgets
