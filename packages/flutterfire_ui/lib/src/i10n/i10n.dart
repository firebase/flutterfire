// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutterfire_ui/src/i10n/default_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'lang/en.dart';

const kDefaultLocale = Locale('en');

class FlutterFireUILocalizations<T extends FlutterFireUILocalizationLabels> {
  final Locale locale;
  final T labels;

  const FlutterFireUILocalizations(this.locale, this.labels);

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

  static FlutterFireUILocalizationLabels labelsOf(BuildContext context) {
    return FlutterFireUILocalizations.of(context).labels;
  }

  static FlutterFireUILocalizationDelegate delegate =
      const FlutterFireUILocalizationDelegate();

  static FlutterFireUILocalizationDelegate
      withDefaultOverrides<T extends EnLocalizations>(T overrides) {
    return FlutterFireUILocalizationDelegate<T>(overrides);
  }
}

class FlutterFireUILocalizationDelegate<
        T extends FlutterFireUILocalizationLabels>
    extends LocalizationsDelegate<FlutterFireUILocalizations> {
  final T? overrides;
  final bool _forceSupportAllLocales;

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
