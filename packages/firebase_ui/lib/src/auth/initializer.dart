import 'dart:async';

import 'package:firebase_ui/firebase_ui.dart';
import 'package:firebase_ui/src/auth/provider_configuration.dart';
import 'package:firebase_ui/src/firebase_ui_initializer.dart';
import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;

class FirebaseUIAuthOptions {
  final List<ProviderConfiguration> providerConfigs;

  FirebaseUIAuthOptions(this.providerConfigs);
}

typedef FlowFactory = AuthFlow Function(FirebaseAuth auth, AuthMethod method);

class FirebaseUIAuthInitializer extends FirebaseUIInitializer {
  FirebaseUIAuthInitializer({
    this.providerConfigs = const [],
  });

  late final _configurations = _buildConfigMap();
  late final _flowFactories = _buildFlowFactories();

  late FirebaseAuth? _auth;
  FirebaseAuth get auth => _auth!;

  List<ProviderConfiguration> providerConfigs;

  @override
  final dependencies = {FirebaseUIAppInitializer};

  @override
  Future<void> initialize([FirebaseUIAuthOptions? params]) async {
    final dep = resolveDependency<FirebaseUIAppInitializer>();
    _auth = FirebaseAuth.instanceFor(app: dep.app);
  }

  Map<String, ProviderConfiguration> _buildConfigMap() {
    return providerConfigs.fold<Map<String, ProviderConfiguration>>(
      {},
      (acc, el) {
        acc[el.providerId] = el;
        return acc;
      },
    );
  }

  Map<Type, FlowFactory> _buildFlowFactories() {
    return providerConfigs.fold<Map<Type, FlowFactory>>({}, (acc, el) {
      acc[el.controllerType] = el.createFlow;
      return acc;
    });
  }

  T configOf<T extends ProviderConfiguration>(String providerId) {
    final config = _configurations[providerId];
    if (config == null) {
      throw Exception(
        'No config for $providerId found. '
        'Make sure to pass a provider configuration to FirebaseUIAuthInitializer for $providerId',
      );
    } else {
      return config as T;
    }
  }

  AuthFlow createFlow<T extends AuthController>(AuthMethod method) {
    final factory = _flowFactories[T];

    if (factory == null) {
      throw Exception(
        'Unknown controller $T. '
        'Make sure to pass provider configuration which registers $T as controllerType',
      );
    }

    return factory(auth, method);
  }
}
