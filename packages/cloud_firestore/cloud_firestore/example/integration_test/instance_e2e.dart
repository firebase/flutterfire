// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void runInstanceTests() {
  group(
    '$FirebaseFirestore.instance',
    () {
      late FirebaseFirestore firestore;

      setUpAll(() async {
        firestore = FirebaseFirestore.instance;
      });

      test(
        'snapshotsInSync()',
        () async {
          DocumentReference<Map<String, dynamic>> documentReference =
              firestore.doc('flutter-tests/insync');

          // Ensure deleted
          await documentReference.delete();

          StreamController controller = StreamController();
          StreamSubscription insync;
          StreamSubscription snapshots;

          int inSyncCount = 0;

          insync = firestore.snapshotsInSync().listen((_) {
            controller.add('insync=$inSyncCount');
            inSyncCount++;
          });

          snapshots = documentReference.snapshots().listen((ds) {
            controller.add('snapshot-exists=${ds.exists}');
          });

          // Allow the snapshots to trigger...
          await Future.delayed(const Duration(seconds: 1));

          await documentReference.set({'foo': 'bar'});

          await expectLater(
            controller.stream,
            emitsInOrder([
              'insync=0', // No other snapshots
              'snapshot-exists=false',
              'insync=1',
              'snapshot-exists=true',
              'insync=2',
            ]),
          );

          await controller.close();
          await insync.cancel();
          await snapshots.cancel();
        },
        skip: kIsWeb,
      );

      test(
        'enableNetwork()',
        () async {
          // Write some data while online
          await firestore.enableNetwork();
          DocumentReference<Map<String, dynamic>> documentReference =
              firestore.doc('flutter-tests/enable-network');
          await documentReference.set({'foo': 'bar'});

          // Disable the network
          await firestore.disableNetwork();

          StreamController controller = StreamController();

          // Set some data while offline
          // ignore: unawaited_futures
          documentReference.set({'foo': 'baz'}).then((_) async {
            // Only when back online will this trigger
            controller.add(true);
          });

          // Go back online
          await firestore.enableNetwork();

          await expectLater(controller.stream, emits(true));
          await controller.close();
        },
        skip: kIsWeb,
      );

      test(
        'disableNetwork()',
        () async {
          // Write some data while online
          await firestore.enableNetwork();
          DocumentReference<Map<String, dynamic>> documentReference =
              firestore.doc('flutter-tests/disable-network');
          await documentReference.set({'foo': 'bar'});

          // Disable the network
          await firestore.disableNetwork();

          // Get data from cache
          DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
              await documentReference.get();
          expect(documentSnapshot.metadata.isFromCache, isTrue);
          expect(documentSnapshot.data()!['foo'], equals('bar'));

          // Go back online once test complete
          await firestore.enableNetwork();
        },
        skip: kIsWeb,
      );

      test(
        'waitForPendingWrites()',
        () async {
          await firestore.waitForPendingWrites();
        },
        skip: kIsWeb,
      );

      test(
        'terminate() / clearPersistence()',
        () async {
          // Since the firestore instance has already been used,
          // calling `clearPersistence` will throw a native error.
          // We first check it does throw as expected, then terminate
          // the instance, and then check whether clearing succeeds.
          try {
            await firestore.clearPersistence();
            fail('Should have thrown');
          } on FirebaseException catch (e) {
            expect(e.code, equals('failed-precondition'));
          } catch (e) {
            fail('$e');
          }

          await firestore.terminate();
          await firestore.clearPersistence();
        },
        skip: kIsWeb || defaultTargetPlatform == TargetPlatform.windows,
      );

      test(
        'setIndexConfiguration()',
        () async {
          Index index1 = Index(
            collectionGroup: 'bar',
            queryScope: QueryScope.collectionGroup,
            fields: [
              IndexField(
                fieldPath: 'fieldPath',
                order: Order.ascending,
                arrayConfig: ArrayConfig.contains,
              ),
            ],
          );

          Index index2 = Index(
            collectionGroup: 'baz',
            queryScope: QueryScope.collection,
            fields: [
              IndexField(
                fieldPath: 'foo',
                arrayConfig: ArrayConfig.contains,
              ),
              IndexField(
                fieldPath: 'bar',
                order: Order.descending,
                arrayConfig: ArrayConfig.contains,
              ),
              IndexField(
                fieldPath: 'baz',
                order: Order.descending,
                arrayConfig: ArrayConfig.contains,
              ),
            ],
          );

          FieldOverrides fieldOverride1 = FieldOverrides(
            fieldPath: 'fieldPath',
            indexes: [
              FieldOverrideIndex(
                queryScope: 'foo',
                order: Order.ascending,
                arrayConfig: ArrayConfig.contains,
              ),
              FieldOverrideIndex(
                queryScope: 'bar',
                order: Order.descending,
                arrayConfig: ArrayConfig.contains,
              ),
              FieldOverrideIndex(
                queryScope: 'baz',
                order: Order.descending,
              ),
            ],
            collectionGroup: 'bar',
          );
          FieldOverrides fieldOverride2 = FieldOverrides(
            fieldPath: 'anotherField',
            indexes: [
              FieldOverrideIndex(
                queryScope: 'foo',
                order: Order.ascending,
                arrayConfig: ArrayConfig.contains,
              ),
              FieldOverrideIndex(
                queryScope: 'bar',
                order: Order.descending,
                arrayConfig: ArrayConfig.contains,
              ),
              FieldOverrideIndex(
                queryScope: 'baz',
                order: Order.descending,
              ),
            ],
            collectionGroup: 'collectiongroup',
          );
          // ignore_for_file: deprecated_member_use
          await firestore.setIndexConfiguration(
            indexes: [index1, index2],
            fieldOverrides: [fieldOverride1, fieldOverride2],
          );
        },
        skip: defaultTargetPlatform == TargetPlatform.windows,
      );

      test(
        'setIndexConfigurationFromJSON()',
        () async {
          final json = jsonEncode({
            'indexes': [
              {
                'collectionGroup': 'posts',
                'queryScope': 'COLLECTION',
                'fields': [
                  {'fieldPath': 'author', 'arrayConfig': 'CONTAINS'},
                  {'fieldPath': 'timestamp', 'order': 'DESCENDING'},
                ],
              }
            ],
            'fieldOverrides': [
              {
                'collectionGroup': 'posts',
                'fieldPath': 'myBigMapField',
                'indexes': [],
              }
            ],
          });

          await firestore.setIndexConfigurationFromJSON(json);
        },
        skip: defaultTargetPlatform == TargetPlatform.windows,
      );

      test('setLoggingEnabled should resolve without issue', () async {
        await FirebaseFirestore.setLoggingEnabled(true);
        await FirebaseFirestore.setLoggingEnabled(false);
      });

      test(
          'Settings() - `persistenceEnabled` & `cacheSizeBytes` with acceptable number',
          () async {
        FirebaseFirestore.instance.settings =
            const Settings(persistenceEnabled: true, cacheSizeBytes: 10000000);
        // Used to trigger settings
        await FirebaseFirestore.instance
            .collection('flutter-tests')
            .doc('new-doc')
            .set(
          {'some': 'data'},
        );
      });

      test(
          'Settings() - `persistenceEnabled` & `cacheSizeBytes` with `Settings.CACHE_SIZE_UNLIMITED`',
          () async {
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
        // Used to trigger settings
        await FirebaseFirestore.instance
            .collection('flutter-tests')
            .doc('new-doc')
            .set(
          {'some': 'data'},
        );
      });

      test('Settings() - `persistenceEnabled` & without `cacheSizeBytes`',
          () async {
        FirebaseFirestore.instance.settings =
            const Settings(persistenceEnabled: true);
        // Used to trigger settings
        await FirebaseFirestore.instance
            .collection('flutter-tests')
            .doc('new-doc')
            .set(
          {'some': 'data'},
        );
      });
      test(
        '`PersistenceCacheIndexManager` with default persistence settings for each platform',
        () async {
          if (defaultTargetPlatform == TargetPlatform.windows) {
            try {
              // Windows does not have `PersistenceCacheIndexManager` support
              FirebaseFirestore.instance.persistentCacheIndexManager();
            } catch (e) {
              expect(e, isInstanceOf<UnimplementedError>());
            }
          } else {
            if (kIsWeb) {
              // persistence is disabled by default on web
              final firestore = FirebaseFirestore.instanceFor(
                app: Firebase.app(),
                // Use different firestore instance to test behavior
                databaseId: 'default-web',
              );
              PersistentCacheIndexManager? indexManager =
                  firestore.persistentCacheIndexManager();
              expect(indexManager, isNull);
            } else {
              final firestore = FirebaseFirestore.instanceFor(
                app: Firebase.app(),
                // Use different firestore instance to test behavior
                databaseId: 'default-other-platform-test',
              );
              // macOS, android, iOS have persistence enabled by default
              PersistentCacheIndexManager? indexManager =
                  firestore.persistentCacheIndexManager();
              await indexManager!.enableIndexAutoCreation();
              await indexManager.disableIndexAutoCreation();
              await indexManager.deleteAllIndexes();
            }
          }
        },
      );

      test(
        '`PersistenceCacheIndexManager` with persistence enabled for each platform',
        () async {
          if (kIsWeb) {
            final firestore = FirebaseFirestore.instanceFor(
              app: Firebase.app(),
              databaseId: 'web-enabled',
            );
            // persistence is disabled by default so we enable it
            firestore.settings = const Settings(persistenceEnabled: true);

            PersistentCacheIndexManager? indexManager =
                firestore.persistentCacheIndexManager();

            await indexManager!.enableIndexAutoCreation();
            await indexManager.disableIndexAutoCreation();
            await indexManager.deleteAllIndexes();

            final firestore2 = FirebaseFirestore.instanceFor(
              app: Firebase.app(),
              databaseId: 'web-disabled-2',
            );

            // Now try using `enablePersistence()`, web only API
            await firestore2.enablePersistence();

            PersistentCacheIndexManager? indexManager2 =
                firestore2.persistentCacheIndexManager();

            await indexManager2!.enableIndexAutoCreation();
            await indexManager2.disableIndexAutoCreation();
            await indexManager2.deleteAllIndexes();
          } else {
            final firestore = FirebaseFirestore.instanceFor(
              app: Firebase.app(),
              databaseId: 'other-platform-enabled',
            );
            firestore.settings = const Settings(persistenceEnabled: true);
            PersistentCacheIndexManager? indexManager =
                firestore.persistentCacheIndexManager();
            await indexManager!.enableIndexAutoCreation();
            await indexManager.disableIndexAutoCreation();
            await indexManager.deleteAllIndexes();
          }
        },
        skip: defaultTargetPlatform == TargetPlatform.windows,
      );

      test(
        '`PersistenceCacheIndexManager` with persistence disabled for each platform',
        () async {
          if (kIsWeb) {
            final firestore = FirebaseFirestore.instanceFor(
              app: Firebase.app(),
              databaseId: 'web-disabled-1',
            );
            // persistence is disabled by default so we enable it
            firestore.settings = const Settings(persistenceEnabled: false);

            PersistentCacheIndexManager? indexManager =
                firestore.persistentCacheIndexManager();

            expect(indexManager, isNull);
          } else {
            final firestore = FirebaseFirestore.instanceFor(
              app: Firebase.app(),
              databaseId: 'other-platform-disabled',
            );
            // macOS, android, iOS have persistence enabled by default so we disable it
            firestore.settings = const Settings(persistenceEnabled: false);
            PersistentCacheIndexManager? indexManager =
                firestore.persistentCacheIndexManager();
            expect(indexManager, isNull);
          }
        },
        skip: defaultTargetPlatform == TargetPlatform.windows,
      );
    },
  );
}
