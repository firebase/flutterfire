import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterfire_ui/src/auth/theme/sign_in_screen_theme.dart';
import 'platform_widget.dart';

class UniversalTextFormField extends PlatformWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final String? Function(String?)? validator;
  final void Function(String?)? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final bool? autofocus;
  final bool? obscureText;
  final FocusNode? focusNode;
  final bool? enableSuggestions;
  final bool? autocorrect;
  final Widget? prefix;
  final SignInScreenTheme? signInScreenTheme;

  const UniversalTextFormField({
    Key? key,
    this.controller,
    this.prefix,
    this.placeholder,
    this.validator,
    this.onSubmitted,
    this.inputFormatters,
    this.keyboardType,
    this.autofocus,
    this.obscureText,
    this.focusNode,
    this.enableSuggestions,
    this.autocorrect,
    this.signInScreenTheme,
  }) : super(key: key);

  @override
  Widget buildCupertino(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: signInScreenTheme?.textColor ?? CupertinoColors.inactiveGray,
          ),
        ),
      ),
      child: CupertinoTextFormFieldRow(
        focusNode: focusNode,
        padding: EdgeInsets.zero,
        controller: controller,
        placeholder: placeholder,
        validator: validator,
        onFieldSubmitted: onSubmitted,
        autofocus: autofocus ?? false,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        obscureText: obscureText ?? false,
        prefix: prefix,
      ),
    );
  }

  @override
  Widget buildMaterial(BuildContext context) {
    return TextFormField(
      autofocus: autofocus ?? false,
      focusNode: focusNode,
      controller: controller,
      cursorColor: signInScreenTheme?.textColor,
      style: TextStyle(color: signInScreenTheme?.textColor),
      decoration: InputDecoration(
          labelText: placeholder,
          labelStyle: TextStyle(
              color: signInScreenTheme?.textColor ?? Color(0xFF000000)),
          prefix: prefix,
      ),
      validator: validator,
      onFieldSubmitted: onSubmitted,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      obscureText: obscureText ?? false,
    );
  }
}
