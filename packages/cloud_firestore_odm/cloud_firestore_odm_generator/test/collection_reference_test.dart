import 'package:expect_error/expect_error.dart';
import 'package:test/test.dart';

Future<void> main() async {
  final library = await Library.custom(
    packageName: 'cloud_firestore_odm_generator_integration_test',
    packageRoot: 'cloud_firestore_odm_generator_integration_test',
    path: 'lib/__test__.dart',
  );

  group('root collections', () {
    test('have no parent', () {
      expect(
        library.withCode(
          '''
import 'simple.dart';

void main() {
  // expect-error: UNDEFINED_GETTER
  rootRef.parent;
}
''',
        ),
        compiles,
      );
    });

    test('property type offset queries from value', () {
      expect(
        library.withCode(
          '''
import 'simple.dart';

void main() {
  // expect-error: ARGUMENT_TYPE_NOT_ASSIGNABLE
  rootRef.orderByNullable(startAt: true);
  // expect-error: ARGUMENT_TYPE_NOT_ASSIGNABLE
  rootRef.orderByNullable(startAfter: true);
  // expect-error: ARGUMENT_TYPE_NOT_ASSIGNABLE
  rootRef.orderByNullable(endAt: true);
  // expect-error: ARGUMENT_TYPE_NOT_ASSIGNABLE
  rootRef.orderByNullable(endBefore: true);

  // expect-error: ARGUMENT_TYPE_NOT_ASSIGNABLE
  rootRef.orderByNonNullable(startAt: null);
  // expect-error: ARGUMENT_TYPE_NOT_ASSIGNABLE
  rootRef.orderByNonNullable(startAfter: null);
  // expect-error: ARGUMENT_TYPE_NOT_ASSIGNABLE
  rootRef.orderByNonNullable(endAt: null);
  // expect-error: ARGUMENT_TYPE_NOT_ASSIGNABLE
  rootRef.orderByNonNullable(endBefore: null);
}
''',
        ),
        compiles,
      );
    });
  });

  group('enum-test collections', () {
    test('simple enum', () {
      expect(
        library.withCode(
          '''
import 'simple.dart';

void main() {
  // expect-error: ARGUMENT_TYPE_NOT_ASSIGNABLE
  enumTestRef.orderByNonNullable(startAt: null);
  // expect-error: ARGUMENT_TYPE_NOT_ASSIGNABLE
  enumTestRef.orderByNonNullable(startAfter: null);
  // expect-error: ARGUMENT_TYPE_NOT_ASSIGNABLE
  enumTestRef.orderByNonNullable(endAt: null);
  // expect-error: ARGUMENT_TYPE_NOT_ASSIGNABLE
  enumTestRef.orderByNonNullable(endBefore: null);
}
''',
        ),
        compiles,
      );
    });
  });
}
