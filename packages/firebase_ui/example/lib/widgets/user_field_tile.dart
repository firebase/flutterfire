import 'package:flutter/material.dart';

class UserFieldTile extends StatelessWidget {
  final String field;
  final String? value;
  final Widget? trailing;

  const UserFieldTile({
    Key? key,
    required this.field,
    required this.value,
    this.trailing,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(field),
      subtitle: Text(value ?? 'unknown'),
      trailing: trailing,
    );
  }
}
