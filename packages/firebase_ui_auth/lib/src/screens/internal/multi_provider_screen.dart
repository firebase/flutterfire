// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

abstract class MultiProviderScreen extends Widget {
  final List<AuthProvider>? _providers;
  final FirebaseAuth? _auth;
  FirebaseAuth get auth {
    return _auth ?? FirebaseAuth.instance;
  }

  const MultiProviderScreen({
    Key? key,
    FirebaseAuth? auth,
    List<AuthProvider>? providers,
  })  : _auth = auth,
        _providers = providers,
        super(key: key);

  List<AuthProvider> get providers {
    if (_providers != null) {
      return _providers!;
    } else {
      return FirebaseUIAuth.providersFor(auth.app);
    }
  }

  Widget build(BuildContext context);

  @override
  ScreenElement createElement() {
    return ScreenElement(this);
  }
}

class ScreenElement extends ComponentElement {
  ScreenElement(Widget widget) : super(widget);

  @override
  MultiProviderScreen get widget => super.widget as MultiProviderScreen;

  @override
  void mount(Element? parent, Object? newSlot) {
    if (widget._providers != null) {
      if (!FirebaseUIAuth.isAppConfigured(widget.auth.app)) {
        FirebaseUIAuth.configureProviders(widget._providers!);
      }
    }

    super.mount(parent, newSlot);
  }

  @override
  Widget build() {
    return widget.build(this);
  }
}
