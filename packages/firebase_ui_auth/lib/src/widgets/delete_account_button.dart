// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/internal/loading_button.dart';

typedef DeleteFailedCallback = void Function(Exception exception);
typedef SignInRequiredCallback = Future<bool> Function();

/// {@template ui.auth.widgets.delete_account_button}
/// A button that triggers the deletion of the user's account.
/// {@endtemplate}
class DeleteAccountButton extends StatefulWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final FirebaseAuth? auth;

  /// A callback tha is called if the [FirebaseAuth] requires the user to
  /// re-authenticate and approve the account deletion. By default,
  /// [ReauthenticateDialog] is being shown.
  final SignInRequiredCallback? onSignInRequired;

  /// A callback that is called if the account deletion fails.
  final DeleteFailedCallback? onDeleteFailed;

  /// {@macro ui.auth.widgets.button_variant}
  final ButtonVariant? variant;

  /// {@macro ui.auth.widgets.delete_account_button}
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
      await FirebaseUIAuth.signOut(context: context, auth: auth);
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
    final l = FirebaseUILocalizations.labelsOf(context);
    bool isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;

    final themeData = Theme.of(context);
    final colorScheme = themeData.colorScheme;

    return LoadingButton(
      isLoading: _isLoading,
      color: isCupertino ? CupertinoColors.destructiveRed : colorScheme.error,
      icon: isCupertino ? CupertinoIcons.delete : Icons.delete,
      label: l.deleteAccount,
      labelColor: colorScheme.onError,
      onTap: _deleteAccount,
      variant: widget.variant,
    );
  }
}
