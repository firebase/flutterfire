import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui/auth.dart';

abstract class ProviderScreen<T extends ProviderConfiguration>
    extends StatelessWidget {
  final T? _config;
  final FirebaseAuth? auth;

  static final _cache = <Type, ProviderConfiguration>{};

  T get config {
    if (_config != null) return _config!;
    if (_cache.containsKey(T)) {
      return _cache[T]! as T;
    }

    final _auth = auth ?? FirebaseAuth.instance;
    final configs = FlutterFireUIAuth.configsFor(_auth.app);
    final config = configs.firstWhere((element) => element is T) as T;
    _cache[T] = config;
    return config;
  }

  const ProviderScreen({Key? key, T? config, this.auth})
      : _config = config,
        super(key: key);
}
