import 'package:firebase_ui/src/i10n/default_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'lang/en.dart';

const kDefaultLocale = Locale('en');

class FirebaseUILocalizations<T extends FirebaseUILocalizationLabels> {
  final Locale locale;
  final T labels;

  const FirebaseUILocalizations(this.locale, this.labels);

  static FirebaseUILocalizations of(BuildContext context) {
    final l = Localizations.of<FirebaseUILocalizations>(
      context,
      FirebaseUILocalizations,
    );

    if (l != null) {
      return l;
    }

    final defaultLocalizations = localizations[kDefaultLocale.languageCode]!;
    return FirebaseUILocalizations(kDefaultLocale, defaultLocalizations);
  }

  static FirebaseUILocalizationLabels labelsOf(BuildContext context) {
    return FirebaseUILocalizations.of(context).labels;
  }

  static FirebaseUILocalizationDelegate delegate =
      const FirebaseUILocalizationDelegate();

  static FirebaseUILocalizationDelegate
      withDefaultOverrides<T extends EnLocalizations>(T overrides) {
    return FirebaseUILocalizationDelegate<T>(overrides);
  }
}

class FirebaseUILocalizationDelegate<T extends FirebaseUILocalizationLabels>
    extends LocalizationsDelegate<FirebaseUILocalizations> {
  final T? overrides;

  const FirebaseUILocalizationDelegate([this.overrides]);

  @override
  bool isSupported(Locale locale) {
    return localizations.keys.contains(locale.languageCode);
  }

  @override
  Future<FirebaseUILocalizations> load(Locale locale) {
    final l = FirebaseUILocalizations(
      locale,
      overrides ?? localizations[locale.languageCode]!,
    );

    return SynchronousFuture<FirebaseUILocalizations>(l);
  }

  @override
  bool shouldReload(
    covariant LocalizationsDelegate<FirebaseUILocalizations> old,
  ) {
    return false;
  }
}
