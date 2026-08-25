// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

Map<String, dynamic> map = <String, dynamic>{
  'number': 123,
  'string': 'foo',
  'booleanTrue': true,
  'booleanFalse': false,
  'null': null,
};

List<dynamic> list = ['1', 2, true, false];

Map<String, dynamic> deepMap = <String, dynamic>{
  ...map,
  'list': list,
  'map': map,
};

List<dynamic> deepList = [
  ...list,
  list,
  map,
];
