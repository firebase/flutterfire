// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io' as io;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'firebase_options.dart';
import 'save_as/save_as.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final emulatorHost =
      (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
          ? '10.0.2.2'
          : 'localhost';

  await FirebaseStorage.instance.useStorageEmulator(emulatorHost, 9199);

  runApp(StorageExampleApp());
}

/// Enum representing the upload task types the example app supports.
enum UploadType {
  /// Uploads a randomly generated string (as a file) to Storage.
  string,

  /// Uploads a file from the device.
  file,

  /// Clears any tasks from the list.
  clear,
}

/// The entry point of the application.
///
/// Returns a [MaterialApp].
class StorageExampleApp extends StatelessWidget {
  StorageExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Storage Example App',
      theme: ThemeData.dark(),
      home: Scaffold(
        body: TaskManager(),
      ),
    );
  }
}

/// A StatefulWidget which keeps track of the current uploaded files.
class TaskManager extends StatefulWidget {
  // ignore: public_member_api_docs
  TaskManager({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TaskManager();
  }
}

class _TaskManager extends State<TaskManager> {
  List<UploadTask> _uploadTasks = [];

  /// The user selects a file, and the task is added to the list.
  Future<UploadTask?> uploadFile(XFile? file) async {
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No file was selected'),
        ),
      );

      return null;
    }

    UploadTask uploadTask;

    // Create a Reference to the file
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('flutter-tests')
        .child('/some-image.jpg');

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'picked-file-path': file.path},
    );

    if (kIsWeb) {
      uploadTask = ref.putData(await file.readAsBytes(), metadata);
    } else {
      uploadTask = ref.putFile(io.File(file.path), metadata);
    }

    return Future.value(uploadTask);
  }

  /// A new string is uploaded to storage.
  UploadTask uploadString() {
    const String putStringText =
        'This upload has been generated using the putString method! Check the metadata too!';

    // Create a Reference to the file
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('flutter-tests')
        .child('/put-string-example.txt');

    // Start upload of putString
    return ref.putString(
      putStringText,
      metadata: SettableMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'example': 'putString'},
      ),
    );
  }

  /// Handles the user pressing the PopupMenuItem item.
  Future<void> handleUploadType(UploadType type) async {
    switch (type) {
      case UploadType.string:
        setState(() {
          _uploadTasks = [..._uploadTasks, uploadString()];
        });
        break;
      case UploadType.file:
        final file = await ImagePicker().pickImage(source: ImageSource.gallery);
        UploadTask? task = await uploadFile(file);

        if (task != null) {
          setState(() {
            _uploadTasks = [..._uploadTasks, task];
          });
        }
        break;
      case UploadType.clear:
        setState(() {
          _uploadTasks = [];
        });
        break;
    }
  }

  void _removeTaskAtIndex(int index) {
    setState(() {
      _uploadTasks = _uploadTasks..removeAt(index);
    });
  }

  Future<void> _downloadBytes(Reference ref) async {
    final bytes = await ref.getData();
    // Download...
    await saveAsBytes(bytes!, 'some-image.jpg');
  }

  Future<void> _downloadLink(Reference ref) async {
    final link = await ref.getDownloadURL();

    await Clipboard.setData(
      ClipboardData(
        text: link,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Success!\n Copied download URL to Clipboard!',
        ),
      ),
    );
  }

  Future<void> _downloadFile(Reference ref) async {
    final io.Directory systemTempDir = io.Directory.systemTemp;
    final io.File tempFile = io.File('${systemTempDir.path}/temp-${ref.name}');
    if (tempFile.existsSync()) await tempFile.delete();

    await ref.writeToFile(tempFile);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Success!\n Downloaded ${ref.name} \n from bucket: ${ref.bucket}\n '
          'at path: ${ref.fullPath} \n'
          'Wrote "${ref.fullPath}" to tmp-${ref.name}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Example App'),
        actions: [
          PopupMenuButton<UploadType>(
            onSelected: handleUploadType,
            icon: const Icon(Icons.add),
            itemBuilder: (context) => [
              const PopupMenuItem(
                // ignore: sort_child_properties_last
                child: Text('Upload string'),
                value: UploadType.string,
              ),
              const PopupMenuItem(
                // ignore: sort_child_properties_last
                child: Text('Upload local file'),
                value: UploadType.file,
              ),
              if (_uploadTasks.isNotEmpty)
                const PopupMenuItem(
                  // ignore: sort_child_properties_last
                  child: Text('Clear list'),
                  value: UploadType.clear,
                )
            ],
          )
        ],
      ),
      body: _uploadTasks.isEmpty
          ? const Center(child: Text("Press the '+' button to add a new file."))
          : ListView.builder(
              itemCount: _uploadTasks.length,
              itemBuilder: (context, index) => UploadTaskListTile(
                task: _uploadTasks[index],
                onDismissed: () => _removeTaskAtIndex(index),
                onDownloadLink: () async {
                  return _downloadLink(_uploadTasks[index].snapshot.ref);
                },
                onDownload: () async {
                  if (kIsWeb) {
                    return _downloadBytes(_uploadTasks[index].snapshot.ref);
                  } else {
                    return _downloadFile(_uploadTasks[index].snapshot.ref);
                  }
                },
              ),
            ),
    );
  }
}

/// Displays the current state of a single UploadTask.
class UploadTaskListTile extends StatelessWidget {
  // ignore: public_member_api_docs
  const UploadTaskListTile({
    Key? key,
    required this.task,
    required this.onDismissed,
    required this.onDownload,
    required this.onDownloadLink,
  }) : super(key: key);

  /// The [UploadTask].
  final UploadTask /*!*/ task;

  /// Triggered when the user dismisses the task from the list.
  final VoidCallback /*!*/ onDismissed;

  /// Triggered when the user presses the download button on a completed upload task.
  final VoidCallback /*!*/ onDownload;

  /// Triggered when the user presses the "link" button on a completed upload task.
  final VoidCallback /*!*/ onDownloadLink;

  /// Displays the current transferred bytes of the task.
  String _bytesTransferred(TaskSnapshot snapshot) {
    return '${snapshot.bytesTransferred}/${snapshot.totalBytes}';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TaskSnapshot>(
      stream: task.snapshotEvents,
      builder: (
        BuildContext context,
        AsyncSnapshot<TaskSnapshot> asyncSnapshot,
      ) {
        Widget subtitle = const Text('---');
        TaskSnapshot? snapshot = asyncSnapshot.data;
        TaskState? state = snapshot?.state;

        if (asyncSnapshot.hasError) {
          if (asyncSnapshot.error is FirebaseException &&
              // ignore: cast_nullable_to_non_nullable
              (asyncSnapshot.error as FirebaseException).code == 'canceled') {
            subtitle = const Text('Upload canceled.');
          } else {
            // ignore: avoid_print
            print(asyncSnapshot.error);
            subtitle = const Text('Something went wrong.');
          }
        } else if (snapshot != null) {
          subtitle = Text('$state: ${_bytesTransferred(snapshot)} bytes sent');
        }

        return Dismissible(
          key: Key(task.hashCode.toString()),
          onDismissed: ($) => onDismissed(),
          child: ListTile(
            title: Text('Upload Task #${task.hashCode}'),
            subtitle: subtitle,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (state == TaskState.running)
                  IconButton(
                    icon: const Icon(Icons.pause),
                    onPressed: task.pause,
                  ),
                if (state == TaskState.running)
                  IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: task.cancel,
                  ),
                if (state == TaskState.paused)
                  IconButton(
                    icon: const Icon(Icons.file_upload),
                    onPressed: task.resume,
                  ),
                if (state == TaskState.success)
                  IconButton(
                    icon: const Icon(Icons.file_download),
                    onPressed: onDownload,
                  ),
                if (state == TaskState.success)
                  IconButton(
                    icon: const Icon(Icons.link),
                    onPressed: onDownloadLink,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
