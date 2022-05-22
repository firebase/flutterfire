import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

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
      return FlutterFireUIAuth.providersFor(auth.app);
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
      if (!FlutterFireUIAuth.isAppConfigured(widget.auth.app)) {
        FlutterFireUIAuth.configureProviders(widget._providers!);
      }
    }

    super.mount(parent, newSlot);
  }

  @override
  Widget build() {
    return widget.build(this);
  }
}
