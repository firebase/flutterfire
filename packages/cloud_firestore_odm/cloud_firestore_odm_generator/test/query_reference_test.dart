import 'package:expect_error/expect_error.dart';
import 'package:test/test.dart';

Future<void> main() async {
  final library = await Library.custom(
    packageName: 'cloud_firestore_odm_generator_integration_test',
    packageRoot: 'cloud_firestore_odm_generator_integration_test',
    path: 'lib/__test__.dart',
  );

  group('query', () {
    test('property type offset queries from value', () {
      expect(
        library.withCode(
          '''
import 'simple.dart';

void main() {
  // expect-error: ARGUMENT_TYPE_NOT_ASSIGNABLE
  rootRef.limit(0).orderByNullable(startAt: true);
  // expect-error: ARGUMENT_TYPE_NOT_ASSIGNABLE
  rootRef.limit(0).orderByNullable(startAfter: true);
  // expect-error: ARGUMENT_TYPE_NOT_ASSIGNABLE
  rootRef.limit(0).orderByNullable(endAt: true);
  // expect-error: ARGUMENT_TYPE_NOT_ASSIGNABLE
  rootRef.limit(0).orderByNullable(endBefore: true);

  // expect-error: ARGUMENT_TYPE_NOT_ASSIGNABLE
  rootRef.limit(0).orderByNonNullable(startAt: null);
  // expect-error: ARGUMENT_TYPE_NOT_ASSIGNABLE
  rootRef.limit(0).orderByNonNullable(startAfter: null);
  // expect-error: ARGUMENT_TYPE_NOT_ASSIGNABLE
  rootRef.limit(0).orderByNonNullable(endAt: null);
  // expect-error: ARGUMENT_TYPE_NOT_ASSIGNABLE
  rootRef.limit(0).orderByNonNullable(endBefore: null);
}
''',
        ),
        compiles,
      );
    });

    test('supports Freezed', () {
      expect(
        library.withCode(
          '''
import 'freezed.dart';

void main() {
  personRef.whereFirstName(isEqualTo: 'foo');
  personRef.orderByFirstName();

  personRef.doc('42').update(firstName: 'foo');
  personRef.doc('42')
    // expect-error: UNDEFINED_NAMED_PARAMETER
    .update(ignored: 42);

  // expect-error: UNDEFINED_METHOD
  personRef.orderByIgnored();
  // expect-error: UNDEFINED_METHOD
  personRef.whereIgnored();
}
''',
        ),
        compiles,
      );
    });
  });
}
