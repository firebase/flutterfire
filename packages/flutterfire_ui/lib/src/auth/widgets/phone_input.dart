import 'package:flutterfire_ui/i10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  static String? getPhoneNumber(GlobalKey<PhoneInputState> key) {
    final state = key.currentState!;

    if (state.formKey.currentState!.validate()) {
      return state.phoneNumber;
    }
  }

  const PhoneInput({
    Key? key,
    this.onSubmit,
  }) : super(key: key);

  @override
  PhoneInputState createState() => PhoneInputState();
}

class PhoneInputState extends State<PhoneInput> {
  final controller = TextEditingController();
  final countryPickerKey = GlobalKey<_CountryPickerState>();
  final formKey = GlobalKey<FormState>();

  String get phoneNumber =>
      '+${countryPickerKey.currentState!.phoneCode}${controller.text}';

  FirebaseUILocalizationLabels get labels =>
      FirebaseUILocalizations.labelsOf(context);

  String? validator(String? value) {
    if (value == null || value.isEmpty) {
      return labels.phoneNumberIsRequiredErrorText;
    }

    if (phoneNumber.length < 11) {
      return labels.phoneNumberInvalidErrorText;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CountryPicker(key: countryPickerKey),
        Expanded(
          child: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: labels.phoneInputLabel,
              ),
              validator: validator,
              onFieldSubmitted: (v) {
                if (formKey.currentState!.validate()) {
                  widget.onSubmit?.call(phoneNumber);
                }
              },
              autofocus: true,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              keyboardType: TextInputType.phone,
            ),
          ),
        ),
      ],
    );
  }
}
