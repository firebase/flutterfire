import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;
import 'package:firebase_ui/i10n.dart';
import 'package:firebase_ui/src/auth/widgets/internal/loading_button.dart';
import 'package:flutter/material.dart';

typedef DeleteFailedCallback = void Function(Exception exception);
typedef SignInRequiredCallback = Future<void> Function();

class DeleteAccountButton extends StatefulWidget {
  final FirebaseAuth? auth;
  final SignInRequiredCallback? onSignInRequired;
  final DeleteFailedCallback? onDeleteFailed;

  const DeleteAccountButton({
    Key? key,
    this.auth,
    this.onSignInRequired,
    this.onDeleteFailed,
  }) : super(key: key);

  @override
  _DeleteAccountButtonState createState() => _DeleteAccountButtonState();
}

class _DeleteAccountButtonState extends State<DeleteAccountButton> {
  FirebaseAuth get auth => widget.auth ?? FirebaseAuth.instance;
  bool _isLoading = false;

  Future<void> _deleteAccount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await auth.currentUser?.delete();
    } on FirebaseAuthException catch (err) {
      if (err.code == 'requires-recent-login') {
        if (widget.onSignInRequired != null) {
          await widget.onSignInRequired!();
          await _deleteAccount();
        }
      }
    } on Exception catch (e) {
      widget.onDeleteFailed?.call(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    return LoadingButton(
      color: Colors.red,
      icon: Icons.delete,
      label: l.deleteAccount,
      onTap: _deleteAccount,
    );
  }
}
