// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

typedef Func0<R> = R Function();
typedef Func1<A, R> = R Function(A a);
typedef Func3<A, B, C, R> = R Function(A a, B b, C c);
typedef Func2Opt1<A, B, R> = R Function(A a, [B b]);
