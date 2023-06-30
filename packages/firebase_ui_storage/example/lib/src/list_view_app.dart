// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_storage/firebase_ui_storage.dart';
import 'package:flutter/material.dart';

import 'apps.dart';

class StorageListViewApp extends StatelessWidget implements App {
  const StorageListViewApp({super.key});

  @override
  String get name => 'StorageListView';

  @override
  Widget build(BuildContext context) {
    return StorageListView(
      ref: FirebaseStorage.instance.ref('list'),
      itemBuilder: (context, ref) {
        return ListTile(
          title: FutureBuilder(
            future: ref.getData(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
              if (snapshot.hasData) {
                return Text(snapshot.data.toString());
              }

              return const Text('Loading...');
            },
          ),
        );
      },
    );
  }
}
