import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/collection_generator.dart';
import 'src/validator_generator.dart';

/// Builds generators for `build_runner` to run
Builder firebase(BuilderOptions options) {
  return SharedPartBuilder(
    [
      CollectionGenerator(),
      ValidatorGenerator(),
    ],
    'firebase',
  );
}
