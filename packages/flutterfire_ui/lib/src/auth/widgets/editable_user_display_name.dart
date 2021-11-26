import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutterfire_ui/i10n.dart';
import 'package:flutter/material.dart';

class EditableUserDisplayName extends StatefulWidget {
  final FirebaseAuth? auth;

  const EditableUserDisplayName({
    Key? key,
    this.auth,
  }) : super(key: key);

  @override
  _EditableUserDisplayNameState createState() =>
      _EditableUserDisplayNameState();
}

class _EditableUserDisplayNameState extends State<EditableUserDisplayName> {
  FirebaseAuth get auth => widget.auth ?? FirebaseAuth.instance;
  String? get displayName => auth.currentUser?.displayName;

  late final ctrl = TextEditingController(text: displayName ?? '');

  late bool _editing = displayName == null;
  bool _isLoading = false;

  void _onEdit() {
    setState(() {
      _editing = true;
    });
  }

  Future<void> _finishEditing() async {
    try {
      if (displayName == ctrl.text) return;

      setState(() {
        _isLoading = true;
      });

      await auth.currentUser?.updateDisplayName(ctrl.text);
      await auth.currentUser?.reload();
    } finally {
      setState(() {
        _editing = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.headline6;
    final l = FirebaseUILocalizations.labelsOf(context);

    if (!_editing) {
      return IntrinsicWidth(
        child: Row(
          children: [
            Text(
              displayName ?? 'Unknown',
              style: style,
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _onEdit,
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: TextField(
            autofocus: true,
            controller: ctrl,
            decoration: InputDecoration(hintText: l.name, labelText: l.name),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 50,
          height: 32,
          child: Stack(
            children: [
              if (_isLoading)
                const Align(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 1),
                  ),
                )
              else
                Align(
                  child: IconButton(
                    icon: const Icon(Icons.check),
                    color: theme.colorScheme.secondary,
                    onPressed: _finishEditing,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
