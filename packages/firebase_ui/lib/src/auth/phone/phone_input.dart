import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'countries.dart';

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
  final SubmitCallback? onSubmitted;

  const PhoneInput({
    Key? key,
    this.onSubmitted,
  }) : super(key: key);

  @override
  PhoneInputState createState() => PhoneInputState();
}

class PhoneInputState extends State<PhoneInput> {
  final controller = TextEditingController();
  final countryPickerKey = GlobalKey<_CountryPickerState>();

  String get phoneNumber =>
      '+${countryPickerKey.currentState!.phoneCode}${controller.text}';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CountryPicker(key: countryPickerKey),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Phone number',
            ),
            onSubmitted: widget.onSubmitted,
            autofocus: true,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            keyboardType: TextInputType.phone,
          ),
        ),
      ],
    );
  }
}
