// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';

class UserAvatar extends StatefulWidget {
  final FirebaseAuth? auth;
  final double? size;
  final ShapeBorder? shape;
  final Color? placeholderColor;

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
