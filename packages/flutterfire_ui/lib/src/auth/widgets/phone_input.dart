// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutterfire_ui/i10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../validators.dart';

import '../widgets/internal/universal_text_form_field.dart';

part '../configs/countries.dart';

class CountryCodeItem {
  final String countryCode;
  final String phoneCode;
  final String name;

  CountryCodeItem({
    required this.countryCode,
    required this.phoneCode,
    required this.name,
  });

  static CountryCodeItem fromJson(Map<String, String> data) {
    return CountryCodeItem(
      countryCode: data['countryCode']!,
      phoneCode: data['phoneCode']!,
      name: data['name']!,
    );
  }
}

typedef SubmitCallback = void Function(String value);

class CountryPicker extends StatefulWidget {
  const CountryPicker({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CountryPickerState createState() => _CountryPickerState();
}

class _CountryPickerState extends State<CountryPicker> {
  String? _countryCode;
  String get countryCode => _countryCode!;
  String get phoneCode => countriesByCountryCode[countryCode]!.phoneCode;

  @override
  Widget build(BuildContext context) {
    _countryCode ??= Localizations.localeOf(context).countryCode;
    final item = countriesByCountryCode[_countryCode]!;

    return PopupMenuButton<CountryCodeItem>(
      onSelected: (selected) => setState(() {
        _countryCode = selected.countryCode;
      }),
      itemBuilder: (context) {
        return countries.map((e) {
          return PopupMenuItem(
            value: e,
            child: Text('${e.name} (+${e.phoneCode})'),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.all(16).copyWith(left: 0),
        child: Row(
          children: [
            const Icon(Icons.arrow_drop_down),
            Text(
              '${item.countryCode} (+${item.phoneCode})',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class PhoneInput extends StatefulWidget {
  final SubmitCallback? onSubmit;
  final String initialCountryCode;

  static String? getPhoneNumber(GlobalKey<PhoneInputState> key) {
    final state = key.currentState!;

    if (state.formKey.currentState!.validate()) {
      return state.phoneNumber;
    }

    return null;
  }

  const PhoneInput({
    Key? key,
    required this.initialCountryCode,
    this.onSubmit,
  }) : super(key: key);

  @override
  PhoneInputState createState() => PhoneInputState();
}

class PhoneInputState extends State<PhoneInput> {
  late final countryController = TextEditingController()
    ..addListener(_onCountryChanged);
  final numberController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final numberFocusNode = FocusNode();

  String get phoneNumber =>
      '+${countryController.text}${numberController.text}';

  String? country;
  bool isValidCountryCode = true;

  CountryCodeItem? countryCodeItem;

  void _onSubmitted(_) {
    if (formKey.currentState!.validate()) {
      widget.onSubmit?.call(phoneNumber);
    }
  }

  @override
  void initState() {
    _setCountry(countryCode: widget.initialCountryCode);
    super.initState();
  }

  void _setCountry({
    String? phoneCode,
    String? countryCode,
    bool updateCountryInput = true,
  }) {
    try {
      final newItem = countries.firstWhere(
        (element) =>
            element.countryCode == countryCode ||
            element.phoneCode == phoneCode,
      );

      if (phoneCode != null &&
          newItem.phoneCode == countryCodeItem?.phoneCode) {
        return;
      }

      countryCodeItem = newItem;
      isValidCountryCode = true;
    } catch (_) {
      countryCodeItem = null;
      isValidCountryCode = false;
    }

    if (updateCountryInput) {
      countryController.text = countryCodeItem?.phoneCode ?? '';
    }
  }

  void _onCountryChanged() {
    setState(() {
      _setCountry(
        phoneCode: countryController.text,
        updateCountryInput: false,
      );
    });
  }

  void _showCountryPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          color: CupertinoTheme.of(context).scaffoldBackgroundColor,
          height: 300,
          child: Column(
            children: [
              Expanded(
                child: CupertinoPicker.builder(
                  useMagnifier: true,
                  itemExtent: 40,
                  childCount: countries.length,
                  onSelectedItemChanged: (i) {
                    setState(() {
                      _setCountry(
                        countryCode: countries.elementAt(i).countryCode,
                      );
                    });
                  },
                  itemBuilder: (context, index) {
                    final item = countries.elementAt(index);
                    return Center(
                      child: Text(
                        '${item.name} (+${item.phoneCode})',
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  },
                ),
              ),
              CupertinoButton(
                child: const Text('Done'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = FlutterFireUILocalizations.labelsOf(context);
    final isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;

    return Form(
      key: formKey,
      child: Column(
        children: [
          if (isCupertino)
            GestureDetector(
              onTap: () {
                _showCountryPicker(context);
              },
              child: Row(
                children: [
                  const Icon(Icons.arrow_drop_down),
                  Text(
                    countryController.text.isNotEmpty && !isValidCountryCode
                        ? l.invalidCountryCode
                        : countryCodeItem?.name ?? l.chooseACountry,
                  ),
                ],
              ),
            )
          else
            PopupMenuButton<CountryCodeItem>(
              child: Container(
                padding: const EdgeInsets.all(16).copyWith(left: 0),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_drop_down),
                    Text(
                      countryController.text.isNotEmpty && !isValidCountryCode
                          ? l.invalidCountryCode
                          : countryCodeItem?.name ?? l.chooseACountry,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              itemBuilder: (context) {
                return countries.map((e) {
                  return PopupMenuItem(
                    value: e,
                    child: Text('${e.name} (+${e.phoneCode})'),
                  );
                }).toList();
              },
              onSelected: (selected) => _setCountry(
                countryCode: selected.countryCode,
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 90,
                child: UniversalTextFormField(
                  autofillHints: const [
                    AutofillHints.telephoneNumberCountryCode
                  ],
                  controller: countryController,
                  prefix: const Text('+'),
                  placeholder: l.countryCode,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.phone,
                  validator: NotEmpty('').validate,
                  onSubmitted: (_) {
                    numberFocusNode.requestFocus();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: UniversalTextFormField(
                  autofillHints: const [AutofillHints.telephoneNumberNational],
                  autofocus: true,
                  focusNode: numberFocusNode,
                  controller: numberController,
                  placeholder: l.phoneInputLabel,
                  validator: Validator.validateAll([
                    NotEmpty(l.phoneNumberIsRequiredErrorText),
                    PhoneValidator(l.phoneNumberInvalidErrorText),
                  ]),
                  onSubmitted: _onSubmitted,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
