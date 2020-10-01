import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await firebase_core.Firebase.initializeApp();
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Storage Example App',
        theme: ThemeData.dark(),
        home: Scaffold(
          body: TaskManager(),
        ));
  }
}

/// A StatefulWidget which keeps track of the current uploaded files.
class TaskManager extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TaskManager();
  }
}

class _TaskManager extends State<TaskManager> {
  List<firebase_storage.UploadTask> _uploadTasks = [];

  /// The user selects a file, and the task is added to the list.
  firebase_storage.UploadTask uploadFile(File file) {
    if (file == null) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text("No file was selected")));
      return null;
    }

    // Create a Reference to the file
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('playground')
        .child('/file-upload-test.txt');

    return ref.putFile(file);
  }

  /// A new string is uploaded to storage.
  firebase_storage.UploadTask uploadString() {
    const String putStringText =
        'This upload has been generated using the putString method! Check the metadata too!';

    // Create a Reference to the file
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('playground')
        .child('/put-string-example.txt');

    // Start upload of putString
    return ref.putString(putStringText,
        metadata: firebase_storage.SettableMetadata(
            contentLanguage: 'en',
            customMetadata: <String, String>{'example': 'putString'}));
  }

  /// Handles the user pressing the PopupMenuItem item.
  void handleUploadType(UploadType type) async {
    switch (type) {
      case UploadType.string:
        setState(() {
          _uploadTasks = [..._uploadTasks, uploadString()];
        });
        break;
      case UploadType.file:
        File file = await FilePicker.getFile();
        firebase_storage.UploadTask task = uploadFile(file);
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

  _removeTaskAtIndex(int index) {
    setState(() {
      _uploadTasks = _uploadTasks..removeAt(index);
    });
  }

  Future<void> _downloadFile(firebase_storage.Reference ref) async {
    final Directory systemTempDir = Directory.systemTemp;
    final File tempFile = File('${systemTempDir.path}/temp-${ref.name}');
    if (tempFile.existsSync()) await tempFile.delete();

    await ref.writeToFile(tempFile);

    Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
      'Success!\n Downloaded ${ref.name} \n from bucket: ${ref.bucket}\n '
      'at path: ${ref.fullPath} \n'
      'Wrote "${ref.fullPath}" to tmp-${ref.name}.txt',
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Storage Example App'),
          actions: [
            PopupMenuButton<UploadType>(
                onSelected: handleUploadType,
                icon: Icon(Icons.add),
                itemBuilder: (context) => [
                      const PopupMenuItem(
                          child: Text("Upload string"),
                          value: UploadType.string),
                      const PopupMenuItem(
                          child: Text("Upload local file"),
                          value: UploadType.file),
                      if (_uploadTasks.isNotEmpty)
                        PopupMenuItem(
                            child: Text("Clear list"), value: UploadType.clear)
                    ])
          ],
        ),
        body: _uploadTasks.isEmpty
            ? Center(child: Text("Press the '+' button to add a new file."))
            : ListView.builder(
                itemCount: _uploadTasks.length,
                itemBuilder: (context, index) => UploadTaskListTile(
                    task: _uploadTasks[index],
                    onDismissed: () => _removeTaskAtIndex(index),
                    onDownload: () =>
                        _downloadFile(_uploadTasks[index].snapshot.ref))));
  }
}

/// Displays the current state of a single UploadTask.
class UploadTaskListTile extends StatelessWidget {
  // ignore: public_member_api_docs
  const UploadTaskListTile(
      {Key key, this.task, this.onDismissed, this.onDownload})
      : super(key: key);

  /// The [UploadTask].
  final firebase_storage.UploadTask task;

  /// Triggered when the user dismisses the task from the list.
  final VoidCallback onDismissed;

  /// Triggered when the user presses the download button on a completed upload task.
  final VoidCallback onDownload;

  /// Displays the current transferred bytes of the task.
  String _bytesTransferred(firebase_storage.TaskSnapshot snapshot) {
    return '${snapshot.bytesTransferred}/${snapshot.totalBytes}';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_storage.TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (BuildContext context,
            AsyncSnapshot<firebase_storage.TaskSnapshot> asyncSnapshot) {
          Widget subtitle = Text('---');
          firebase_storage.TaskSnapshot snapshot = asyncSnapshot.data;
          firebase_storage.TaskState state = snapshot?.state;

          if (asyncSnapshot.hasError) {
            if (asyncSnapshot.error is firebase_core.FirebaseException &&
                (asyncSnapshot.error as firebase_core.FirebaseException).code ==
                    'canceled') {
              subtitle = Text('Upload canceled.');
            } else {
              print(asyncSnapshot.error);
              subtitle = Text('Something went wrong.');
            }
          } else if (snapshot != null) {
            subtitle =
                Text('${state}: ${_bytesTransferred(snapshot)} bytes sent');
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
                  if (state == firebase_storage.TaskState.running)
                    IconButton(
                      icon: Icon(Icons.pause),
                      onPressed: () => task.pause(),
                    ),
                  if (state == firebase_storage.TaskState.running)
                    IconButton(
                      icon: Icon(Icons.cancel),
                      onPressed: () => task.cancel(),
                    ),
                  if (state == firebase_storage.TaskState.paused)
                    IconButton(
                      icon: Icon(Icons.file_upload),
                      onPressed: () => task.resume(),
                    ),
                  if (state == firebase_storage.TaskState.success)
                    IconButton(
                      icon: Icon(Icons.file_download),
                      onPressed: () => onDownload(),
                    ),
                ],
              ),
            ),
          );
        });
  }
}
