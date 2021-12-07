import 'package:flutter/material.dart';

class UserFieldTile extends StatelessWidget {
  final String field;
  final String? value;
  final Widget? trailing;
  final Widget? child;

  const UserFieldTile({
    Key? key,
    required this.field,
    this.value,
    this.trailing,
    this.child,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(field),
      subtitle: child ?? Text(value ?? 'unknown'),
      trailing: trailing,
    );
  }
}
