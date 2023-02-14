# Localization

Firebase UI for Flutter supports localization, so every single label can be customized.

## Installation

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  firebase_ui_localizations: ^1.2.0
```

## Usage

If your app supports only a single language, and you want to override labels – you will need to provide a custom class that implements [`DefaultLocalizations`](https://pub.dev/documentation/firebase_ui_localizations/latest/DefaultLocalizations-class.html),
for example:

```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';

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
        FirebaseUILocalizations.withDefaultOverrides(const LabelOverrides()),

        // Delegates below take care of built-in flutter widgets
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,

        // This delegate is required to provide the labels that are not overridden by LabelOverrides
        FirebaseUILocalizations.delegate,
      ],
      // ...
    );
  }
}
```

If you need to support multiple languages – follow the [official Flutter localization guide](https://docs.flutter.dev/development/accessibility-and-localization/internationalization#an-alternative-class-for-the-apps-localized-resources)
and make sure that your custom delegate extends `LocalizationsDelegate<FirebaseUILocalizations>`.

> Note: check out [API reference](https://pub.dev/documentation/firebase_ui_localizations/latest/FlutterFireUILocalizationLabels-class.html) to learn what labels are used by specific widgets
