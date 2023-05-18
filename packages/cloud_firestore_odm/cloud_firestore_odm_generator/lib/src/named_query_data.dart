// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:recase/recase.dart';

import 'names.dart';

class NamedQueryData with Names {
  NamedQueryData(this.queryName, {required this.type});

  factory NamedQueryData.fromAnnotation(DartObject dartObject) {
    final queryName = dartObject.getField('queryName')!.toStringValue()!;

    final genericType =
        (dartObject.type! as InterfaceType).typeArguments.single;

    return NamedQueryData(queryName, type: genericType);
  }

  @override
  final DartType type;

  final String queryName;

  late final String namedQueryGetName = '${ReCase(queryName).camelCase}Get';
  late final String namedQueryExtensionName =
      '${ReCase(queryName).pascalCase}Extrension';

  @override
  String? get collectionPrefix => null;
}
