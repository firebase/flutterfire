// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_ui_storage_example/main.dart';
import 'package:firebase_ui_storage_example/src/storage_image_app.dart';
import 'package:flutter/material.dart';

import 'progress_bar_app.dart';
import 'upload_button_app.dart';

abstract class App implements Widget {
  String get name;
}

const apps = <App>[
  UploadButtonApp(),
  ProgressBarApp(),
  StorageImageApp(),
];

class AppList extends StatelessWidget {
  const AppList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: apps.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            child: ValueListenableBuilder(
              valueListenable: brightness,
              builder: (context, brightness, child) {
                return ValueListenableBuilder(
                  valueListenable: app,
                  builder: (context, app, _) {
                    var tileColor = Colors.transparent;

                    if (app == apps[index]) {
                      tileColor = brightness == Brightness.light
                          ? Colors.black.withAlpha(20)
                          : Colors.white.withAlpha(20);
                    }
                    return Container(
                      decoration: BoxDecoration(
                        color: tileColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: child,
                    );
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16,
                ),
                child: Text(apps[index].name),
              ),
            ),
            onTap: () => app.value = apps[index],
          ),
        );
      },
    );
  }
}
