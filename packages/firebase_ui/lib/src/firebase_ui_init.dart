import 'package:firebase_ui/firebase_ui.dart';
import 'package:firebase_ui/responsive.dart';
import 'package:firebase_ui/src/firebase_ui_initializer.dart';
import 'package:flutter/material.dart';

class FirebaseUIInit extends InheritedWidget {
  static FirebaseUIInit? _instance;

  static Widget builder(BuildContext context, Widget? widget) {
    return ResponsiveGridOverlay(
      child: widget,
    );
  }

  final List<FirebaseUIInitializer> initializers;
  late final Map<Type, FirebaseUIInitializer> _initializersMap;

  factory FirebaseUIInit({
    required Widget child,
    required List<FirebaseUIInitializer> initializers,
  }) =>
      _instance ??= FirebaseUIInit._(
        initializers: initializers,
        child: child,
      );

  FirebaseUIInit._({
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

  static T getInitializerOfType<T>(BuildContext context) {
    final _initializersMap = context
        .dependOnInheritedWidgetOfExactType<FirebaseUIInit>()!
        ._initializersMap;

    final initializer = _initializersMap[T];

    if (initializer == null) {
      throw Exception('No $T found');
    }

    return initializer as T;
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

mixin InitializerProvider {
  T getInitializerOfType<T>(BuildContext context) {
    return FirebaseUIInit.getInitializerOfType<T>(context)!;
  }
}

class FirebaseUIAppElement extends InheritedElement {
  FirebaseUIAppElement(InheritedWidget widget) : super(widget);

  @override
  FirebaseUIInit get widget => super.widget as FirebaseUIInit;

  @override
  Widget build() {
    return InitializersBinding(
      initializers: widget._initializersMap,
      child: widget.child,
    );
  }
}

typedef ErrorBuilder = Widget Function(BuildContext context, Object error);

class InitializersBinding extends StatefulWidget {
  final Map<Type, FirebaseUIInitializer> initializers;
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
  FirebaseUIAppInitializer get rootInitializer =>
      widget.initializers[FirebaseUIAppInitializer]!
          as FirebaseUIAppInitializer;

  late Future<List> ready;

  @override
  void initState() {
    ready = init();
    super.initState();
  }

  List<FirebaseUIInitializer> resolveDependencies(Set<Type> dependencies) {
    return dependencies.map((e) => widget.initializers[e]!).toList();
  }

  Future invokeInitializer(FirebaseUIInitializer initializer) {
    final deps = resolveDependencies(initializer.dependencies);
    final depsMap = deps.fold<Map<Type, FirebaseUIInitializer>>(
      {},
      (map, dep) => {
        ...map,
        dep.runtimeType: dep,
      },
    );

    DependencyManager.inject(initializer, depsMap);

    return initializer.initialize();
  }

  Future<List> init() async {
    await rootInitializer.initialize();
    final orderedInitializers = <FirebaseUIInitializer>[];
    final rest = {...widget.initializers}..remove(FirebaseUIAppInitializer);

    void resolveInitPriority(FirebaseUIInitializer initializer) {
      if (initializer.dependencies.isNotEmpty) {
        initializer.dependencies
            .map((t) => widget.initializers[t]!)
            .forEach(resolveInitPriority);
      }

      orderedInitializers.add(initializer);
      rest.remove(initializer.runtimeType);
    }

    while (rest.isNotEmpty) {
      resolveInitPriority(rest.values.first);
    }

    final futures = orderedInitializers.map(invokeInitializer);
    return Future.wait(futures);
  }

  Widget buildSplashScreen() {
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
            return buildSplashScreen();
          }
        } else {
          return buildSplashScreen();
        }
      },
    );
  }
}
