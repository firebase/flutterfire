import 'package:expect_error/expect_error.dart';
import 'package:test/test.dart';

Future<void> main() async {
  final library = await Library.custom(
    packageName: 'cloud_firestore_odm_generator_integration_test',
    packageRoot: 'cloud_firestore_odm_generator_integration_test',
    path: 'lib/__test__.dart',
  );

  group('update', () {
    test('types parameters', () {
      expect(
        library.withCode(
          '''
import 'simple.dart';

void main() {
  rootRef.doc('42').update(
    nullable: null,
  );
  rootRef.doc('42').update(
    nullable: 42,
  );
  rootRef.doc('42').update(
    // expect-error: ARGUMENT_TYPE_NOT_ASSIGNABLE
    nullable: 'string',
  );

  rootRef.doc('42').update(
    // expect-error: ARGUMENT_TYPE_NOT_ASSIGNABLE
    nonNullable: null,
  );
  rootRef.doc('42').update(
    nonNullable: '42',
  );
  rootRef.doc('42').update(
    // expect-error: ARGUMENT_TYPE_NOT_ASSIGNABLE
    nonNullable: 42,
  );
}
''',
        ),
        compiles,
      );
    });
  });

  group('set', () {
    test('types parameters', () {
      expect(
        library.withCode(
          '''
import 'simple.dart';

void main() {
  Root root = null as Root;

  rootRef.doc('42').set(root);

  rootRef.doc('42')
    // expect-error: ARGUMENT_TYPE_NOT_ASSIGNABLE
    .set(42);
}
''',
        ),
        compiles,
      );
    });
  });
}
