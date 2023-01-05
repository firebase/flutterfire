// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';

/// {@template ui.auth.widgets.user_avatar}
///
/// A widget that displays the user's avatar.
///
/// Shows a placeholder if user doesn't have a profile photo.
/// {@endtemplate}
class UserAvatar extends StatefulWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final FirebaseAuth? auth;

  /// {@template ui.auth.widgets.user_avatar.size}
  /// A size of the avatar.
  /// {@endtemplate}
  final double? size;

  /// {@template ui.auth.widgets.user_avatar.shape}
  /// A shape of the avatar.
  /// A [CircleBorder] is used by default.
  /// {@endtemplate}
  final ShapeBorder? shape;

  /// {@template ui.auth.widgets.user_avatar.placeholder_color}
  /// A color of the avatar placeholder.
  /// {@endtemplate}
  final Color? placeholderColor;

  /// {@macro ui.auth.widgets.user_avatar}
  const UserAvatar({
    Key? key,
    this.auth,
    this.size,
    this.shape,
    this.placeholderColor,
  }) : super(key: key);

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  FirebaseAuth get auth => widget.auth ?? FirebaseAuth.instance;
  ShapeBorder get shape => widget.shape ?? const CircleBorder();
  Color get placeholderColor => widget.placeholderColor ?? Colors.grey;
  double get size => widget.size ?? 120;

  late String? photoUrl = auth.currentUser?.photoURL;

  Widget _imageFrameBuilder(
    BuildContext context,
    Widget? child,
    int? frame,
    bool? _,
  ) {
    if (frame == null) {
      return Container(color: placeholderColor);
    }

    return child!;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: ClipPath(
        clipper: ShapeBorderClipper(shape: shape),
        clipBehavior: Clip.hardEdge,
        child: photoUrl != null
            ? Image.network(
                photoUrl!,
                width: size,
                height: size,
                cacheWidth: size.toInt(),
                cacheHeight: size.toInt(),
                fit: BoxFit.cover,
                frameBuilder: _imageFrameBuilder,
              )
            : Center(
                child: Icon(
                  Icons.account_circle,
                  size: size,
                  color: placeholderColor,
                ),
              ),
      ),
    );
  }
}
