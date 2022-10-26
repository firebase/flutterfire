// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:expect_error/expect_error.dart';
import 'package:test/test.dart';

Future<void> main() async {
  final library = await Library.custom(
    packageName: 'cloud_firestore_odm_generator_integration_test',
    packageRoot: 'cloud_firestore_odm_generator_integration_test',
    path: 'lib/__test__.dart',
  );

  group('where(arrayContains)', () {
    test(' is typed', () {
      expect(
        library.withCode(
          '''
import 'simple.dart';

void main() {
  // Does not arrayContains for non-list
  // expect-error: UNDEFINED_METHOD
  nestedRef.whereValue();
  nestedRef.whereSimple(
    // expect-error: UNDEFINED_NAMED_PARAMETER
    arrayContains: null,
  );
  // expect-error: UNDEFINED_METHOD
  nestedRef.whereValueList();

  nestedRef.whereNumList(arrayContains: 42);
  nestedRef.whereNumList(
    // expect-error: ARGUMENT_TYPE_NOT_ASSIGNABLE
    arrayContains: 'string',
  );
}
''',
        ),
        compiles,
      );
    });
  });

  group('update', () {
    test('rejects complex object list but allows primitive lists', () {
      expect(
        library.withCode(
          '''
import 'simple.dart';

void main() {
  nestedRef.doc('42').update(
    // expect-error: UNDEFINED_NAMED_PARAMETER
    value: null,
  );
  nestedRef.doc('42').update(
    // expect-error: UNDEFINED_NAMED_PARAMETER
    valueList: null,
  );
  nestedRef.doc('42').update(
    boolList: null,
  );
  nestedRef.doc('42').update(
    stringList: null,
  );
  nestedRef.doc('42').update(
    numList: null,
  );
  nestedRef.doc('42').update(
    objectList: null,
  );
  nestedRef.doc('42').update(
    dynamicList: null,
  );  
}
''',
        ),
        compiles,
      );
    });

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
