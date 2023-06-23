// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_storage/firebase_ui_storage.dart';
import 'package:flutter/material.dart';

import 'apps.dart';

const preloadedBlurhash = ':eDJq[9wo~xUbKNexqWG-@M|xuRlt7ayWVoMIwskxVIvs+slNHt'
    '2j]j?RiocR%fRo0oJtRW=V@t2R*bHoMfSbca#oJaybHj@flbIsoWCbHaya}bHoeazbIayofWC'
    'n~j[R*oJ';

class StorageImageApp extends StatelessWidget implements App {
  const StorageImageApp({super.key});

  @override
  String get name => 'StorageImage';

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: StorageImage(
            ref: FirebaseStorage.instance.ref().child('dash_and_sparky.png'),
            fit: BoxFit.cover,
            loadingStateVariant: LoadingStateVariant.blurHash(
              value: preloadedBlurhash,
            ),
          ),
        ),
        AspectRatio(
          aspectRatio: 4 / 3,
          child: StorageImage(
            ref: FirebaseStorage.instance.ref().child('dash_laptop.png'),
            fit: BoxFit.cover,
          ),
        ),
        AspectRatio(
          aspectRatio: 4 / 3,
          child: StorageImage(
            ref: FirebaseStorage.instance.ref().child('dash_laptop.png'),
            fit: BoxFit.cover,
            loadingStateVariant: LoadingStateVariant.loadingIndicator(),
          ),
        ),
        AspectRatio(
          aspectRatio: 4 / 3,
          child: StorageImage(
            ref: FirebaseStorage.instance.ref().child('dash_and_sparky.png'),
            fit: BoxFit.cover,
            loadingStateVariant: LoadingStateVariant.blurHash(),
          ),
        ),
      ],
    );
  }
}
