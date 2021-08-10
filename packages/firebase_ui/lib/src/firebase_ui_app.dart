import 'package:firebase_ui/firebase_ui.dart';
import 'package:firebase_ui/src/firebase_ui_initializer.dart';
import 'package:flutter/material.dart';

class FirebaseUIApp extends InheritedWidget {
  static FirebaseUIApp? _instance;

  final List<FirebaseUIInitializer> initializers;
  late final Map<Type, FirebaseUIInitializer> _initializersMap;

  factory FirebaseUIApp({
    required Widget child,
    required List<FirebaseUIInitializer> initializers,
  }) =>
      _instance ??= FirebaseUIApp._(
        initializers: initializers,
        child: child,
      );

  FirebaseUIApp._({
    required Widget child,
    required this.initializers,
  }) : super(child: child) {
    _initializersMap = initializers.fold({}, (previousValue, element) {
      return {
        ...previousValue,
        element.runtimeType: element,
      };
    });
  }

  static T initializerOf<T>(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<FirebaseUIApp>()!
        ._initializersMap[T]! as T;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }

  @override
  InheritedElement createElement() {
    return FirebaseUIAppElement(this);
  }
}

class FirebaseUIAppElement extends InheritedElement {
  FirebaseUIAppElement(InheritedWidget widget) : super(widget);

  @override
  FirebaseUIApp get widget => super.widget as FirebaseUIApp;

  @override
  Widget build() {
    return InitializersBinding(
      initializers: widget.initializers,
      child: widget.child,
    );
  }
}

typedef ErrorBuilder = Widget Function(BuildContext context, Object error);

class InitializersBinding extends StatefulWidget {
  final List<FirebaseUIInitializer> initializers;
  final Widget child;
  final WidgetBuilder? splashScreenBuilder;
  final ErrorBuilder? errorBuilder;
  const InitializersBinding({
    Key? key,
    required this.initializers,
    required this.child,
    this.splashScreenBuilder,
    this.errorBuilder,
  }) : super(key: key);

  @override
  _InitializersBindingState createState() => _InitializersBindingState();
}

class _InitializersBindingState extends State<InitializersBinding> {
  late final ready = widget.initializers
      .whereType<FirebaseUIAppInitializer>()
      .first
      .initialize()
      .then(
        (v) =>
            Future.wait(widget.initializers.map((i) => i.initialize(i.params))),
      );

  Widget buildSlashScreen() {
    return widget.splashScreenBuilder?.call(context) ??
        const SizedBox(width: 0, height: 0);
  }

  Widget buildError(AsyncSnapshot snapshot) {
    return widget.errorBuilder?.call(context, snapshot.error!) ??
        Text(snapshot.error.toString());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ready,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return widget.child;
          } else if (snapshot.hasError) {
            return buildError(snapshot);
          } else {
            return buildSlashScreen();
          }
        } else {
          return buildSlashScreen();
        }
      },
    );
  }
}
