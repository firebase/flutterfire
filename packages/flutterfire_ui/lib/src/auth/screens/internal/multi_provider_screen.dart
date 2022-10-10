// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

abstract class MultiProviderScreen extends Widget {
  final List<ProviderConfiguration>? _providerConfigs;
  final FirebaseAuth? _auth;
  FirebaseAuth get auth {
    return _auth ?? FirebaseAuth.instance;
  }

  const MultiProviderScreen({
    Key? key,
    FirebaseAuth? auth,
    List<ProviderConfiguration>? providerConfigs,
  })  : _auth = auth,
        _providerConfigs = providerConfigs,
        super(key: key);

  List<ProviderConfiguration> get providerConfigs {
    if (_providerConfigs != null) {
      return _providerConfigs!;
    } else {
      return FlutterFireUIAuth.configsFor(auth.app);
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
    if (widget._providerConfigs != null) {
      if (!FlutterFireUIAuth.isAppConfigured(widget.auth.app)) {
        FlutterFireUIAuth.configureProviders(widget._providerConfigs!);
      }
    }

    super.mount(parent, newSlot);
  }

  @override
  Widget build() {
    return widget.build(this);
  }
}
