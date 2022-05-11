import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;
import 'package:flutter/cupertino.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/i10n.dart';
import '../widgets/internal/loading_button.dart';

typedef DeleteFailedCallback = void Function(Exception exception);
typedef SignInRequiredCallback = Future<bool> Function();

class DeleteAccountButton extends StatefulWidget {
  final FirebaseAuth? auth;
  final SignInRequiredCallback? onSignInRequired;
  final DeleteFailedCallback? onDeleteFailed;
  final ButtonVariant? variant;

  const DeleteAccountButton({
    Key? key,
    this.auth,
    this.onSignInRequired,
    this.onDeleteFailed,
    this.variant,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
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
      await FlutterFireUIAuth.signOut(context: context, auth: auth);
    } on FirebaseAuthException catch (err) {
      if (err.code == 'requires-recent-login') {
        if (widget.onSignInRequired != null) {
          final signedIn = await widget.onSignInRequired!();
          if (signedIn) {
            await _deleteAccount();
          }
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
    final l = FlutterFireUILocalizations.labelsOf(context);
    bool isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;

    return LoadingButton(
      isLoading: _isLoading,
      color: isCupertino ? CupertinoColors.destructiveRed : Colors.red,
      icon: isCupertino ? CupertinoIcons.delete : Icons.delete,
      label: l.deleteAccount,
      onTap: _deleteAccount,
      variant: widget.variant,
    );
  }
}
