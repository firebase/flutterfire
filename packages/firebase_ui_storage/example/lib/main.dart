// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_shared/firebase_ui_shared.dart';
import 'package:firebase_ui_storage/firebase_ui_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'src/apps.dart';

enum DesignLib {
  material(Icons.android),
  cupertino(Icons.apple);

  final IconData icon;
  const DesignLib(this.icon);
}

final designLib = ValueNotifier(DesignLib.material);
final brightness = ValueNotifier(Brightness.light);
final app = ValueNotifier(apps[0]);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);

  final storage = FirebaseStorage.instance;

  final config = FirebaseUIStorageConfiguration(
    storage: storage,
    uploadRoot: storage.ref('flutter-tests'),
  );

  await FirebaseUIStorage.configure(config);

  runApp(const FirebaseUIStorageGallery());
}

class FirebaseUIStorageGallery extends StatelessWidget {
  const FirebaseUIStorageGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: designLib,
      builder: (context, design, _) {
        return ValueListenableBuilder(
          valueListenable: brightness,
          builder: (context, brightness, _) {
            switch (design) {
              case DesignLib.material:
                return buildMaterial(context, brightness);
              case DesignLib.cupertino:
                return buildCupertino(context, brightness);
            }
          },
        );
      },
    );
  }

  Widget buildMaterial(BuildContext context, Brightness brightness) {
    return MaterialApp(
      title: 'Firebase UI Storage Gallery',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: brightness,
        useMaterial3: true,
      ),
      home: const Gallery(),
    );
  }

  Widget buildCupertino(BuildContext context, Brightness brightness) {
    return CupertinoApp(
      title: 'Firebase UI Storage Gallery',
      theme: CupertinoThemeData(
        brightness: brightness,
      ),
      home: const Gallery(),
    );
  }
}

class Gallery extends StatelessWidget {
  const Gallery({super.key});

  @override
  Widget build(BuildContext context) {
    return UniversalScaffold(
      body: Column(
        children: [
          const Toolbar(),
          Expanded(
            child: Row(
              children: [
                const SizedBox(
                  width: 200,
                  child: AppList(),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: app,
                        builder: (context, app, _) => Expanded(
                          child: Center(child: app),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Toolbar extends PlatformWidget {
  const Toolbar({super.key});

  @override
  Widget buildCupertino(BuildContext context) {
    final currentBrigtness = CupertinoTheme.of(context).brightness;

    const padding = EdgeInsets.symmetric(vertical: 2, horizontal: 8);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text('Brightness'),
        CupertinoSegmentedControl<Brightness>(
          children: const <Brightness, Widget>{
            Brightness.light: Padding(
              padding: padding,
              child: Icon(Icons.light_mode),
            ),
            Brightness.dark: Padding(
              padding: padding,
              child: Icon(Icons.dark_mode),
            ),
          },
          onValueChanged: (value) {
            brightness.value = value;
          },
          groupValue: currentBrigtness,
        ),
        const Text('Design Library'),
        CupertinoSegmentedControl<DesignLib>(
          children: const <DesignLib, Widget>{
            DesignLib.material: Padding(
              padding: padding,
              child: Icon(Icons.android),
            ),
            DesignLib.cupertino: Padding(
              padding: padding,
              child: Icon(Icons.apple),
            ),
          },
          onValueChanged: (value) {
            designLib.value = value;
          },
          groupValue: designLib.value,
        ),
      ],
    );
  }

  @override
  Widget buildMaterial(BuildContext context) {
    final currentBrigtness = Theme.of(context).brightness;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text('Brightness'),
        const SizedBox(width: 16),
        ToggleButtons(
          onPressed: (index) {
            brightness.value = index == 0 ? Brightness.light : Brightness.dark;
          },
          isSelected: [
            currentBrigtness == Brightness.light,
            currentBrigtness == Brightness.dark,
          ],
          children: const <Widget>[
            Icon(Icons.light_mode),
            Icon(Icons.dark_mode),
          ],
        ),
        const SizedBox(width: 16),
        const Text('Design Library'),
        const SizedBox(width: 16),
        ToggleButtons(
          isSelected: [
            designLib.value == DesignLib.material,
            designLib.value == DesignLib.cupertino,
          ],
          onPressed: (index) {
            designLib.value =
                index == 0 ? DesignLib.material : DesignLib.cupertino;
          },
          children: const <Widget>[
            Icon(Icons.android),
            Icon(Icons.apple),
          ],
        ),
      ],
    );
  }

  @override
  Widget? buildWrapper(BuildContext context, Widget child) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: child,
    );
  }
}
