import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'default_localizations.dart';


const kDefaultLocale = Locale('en');

/// {@template ffui.i10n.localizations}
/// Could be used to obtain FlutterFire UI localization labels
/// via [BuildContext] (using [labelsOf] )and to override default localizations
/// (using [withDefaultOverrides]).
/// {@endtemplate}
class FlutterFireUILocalizations<T extends FlutterFireUILocalizationLabels> {
  final Locale locale;
  final T labels;

  /// {@macro ffui.i10n.localizations}
  const FlutterFireUILocalizations(this.locale, this.labels);

  /// Looks up an instance of the [FlutterFireUILocalizations] on the
  /// [BuildContext].
  ///
  /// To obtain labels, use [labelsOf].
  static FlutterFireUILocalizations of(BuildContext context) {
    final l = Localizations.of<FlutterFireUILocalizations>(
      context,
      FlutterFireUILocalizations,
    );

    if (l != null) {
      return l;
    }

    final defaultLocalizations = localizations[kDefaultLocale.languageCode]!;
    return FlutterFireUILocalizations(kDefaultLocale, defaultLocalizations);
  }

  /// Returns localization labels.
  static FlutterFireUILocalizationLabels labelsOf(BuildContext context) {
    return FlutterFireUILocalizations.of(context).labels;
  }

  /// Localization delegate that could be provided to the
  /// [MaterialApp.localizationsDelegates].
  static FlutterFireUILocalizationDelegate delegate =
      const FlutterFireUILocalizationDelegate();

  /// Should be used to override labels provided by the library.
  ///
  /// See [FlutterFireUILocalizationLabels].
  static FlutterFireUILocalizationDelegate
      withDefaultOverrides<T extends DefaultLocalizations>(T overrides) {
    return FlutterFireUILocalizationDelegate<T>(overrides);
  }
}

/// See [LocalizationsDelegate]
class FlutterFireUILocalizationDelegate<
        T extends FlutterFireUILocalizationLabels>
    extends LocalizationsDelegate<FlutterFireUILocalizations> {
  /// An instance of the class that overrides some labels.
  /// See [FlutterFireUILocalizationLabels].
  final T? overrides;
  final bool _forceSupportAllLocales;

  /// See [LocalizationsDelegate].
  const FlutterFireUILocalizationDelegate([
    this.overrides,
    this._forceSupportAllLocales = false,
  ]);

  @override
  bool isSupported(Locale locale) {
    return _forceSupportAllLocales ||
        localizations.keys.contains(locale.languageCode);
  }

  @override
  Future<FlutterFireUILocalizations> load(Locale locale) {
    final l = FlutterFireUILocalizations(
      locale,
      overrides ?? localizations[locale.languageCode]!,
    );

    return SynchronousFuture<FlutterFireUILocalizations>(l);
  }

  @override
  bool shouldReload(
    covariant LocalizationsDelegate<FlutterFireUILocalizations> old,
  ) {
    return false;
  }
}
