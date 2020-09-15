import 'dart:io';
import 'package:e2e/e2e.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uuid/uuid.dart';

// TODO(Salakar): see http related todo further down.
// import 'package:http/http.dart' as http;

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  const String kTestString = 'hello world';
  FirebaseStorage firebaseStorage;

  setUpAll(() async {
    await Firebase.initializeApp();
    firebaseStorage = FirebaseStorage();
  });

  testWidgets('FirebaseStorage -> putFile, getDownloadURL, writeToFile',
      (WidgetTester tester) async {
    final String uuid = Uuid().v1();
    final Directory systemTempDir = Directory.systemTemp;
    final File file = await File('${systemTempDir.path}/foo$uuid.txt').create();
    await file.writeAsString(kTestString);
    final StorageReference ref =
        firebaseStorage.ref().child('text').child('foo$uuid.txt');
    expect(await ref.getName(), 'foo$uuid.txt');
    expect(await ref.getPath(), 'text/foo$uuid.txt');
    final StorageUploadTask uploadTask = ref.putFile(
      file,
      StorageMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'test'},
      ),
    );
    final StorageTaskSnapshot complete = await uploadTask.onComplete;
    expect(complete.storageMetadata.sizeBytes, kTestString.length);
    expect(complete.storageMetadata.contentLanguage, 'en');
    expect(complete.storageMetadata.customMetadata['activity'], 'test');

    final String url = await ref.getDownloadURL();
    print(url);
    // TODO(Salakar): this http.get has recently started failing, request returns a
    //   400 status code even though printing out the link and manually opening it
    //   in a browser works - so the link itself is functioning as expected. These
    //   tests will be re-written during upcoming rework.
    // final http.Response downloadData = await http.get(url);
    // expect(downloadData.body, kTestString);
    // expect(downloadData.headers['content-type'], 'text/plain');

    final File tempFile = File('${systemTempDir.path}/tmp$uuid.txt');
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }
    await tempFile.create();
    expect(await tempFile.readAsString(), '');

    final StorageFileDownloadTask invalidTask =
        ref.child("invalid").writeToFile(tempFile);
    Exception taskException;
    try {
      (await invalidTask.future).totalByteCount;
    } catch (e) {
      taskException = e;
    }
    expect(taskException, isNotNull);

    final StorageFileDownloadTask task = ref.writeToFile(tempFile);
    int byteCount = 0;
    try {
      byteCount = (await task.future).totalByteCount;
    } catch (e) {
      // Unexpected exception
    }
    final String tempFileContents = await tempFile.readAsString();
    expect(tempFileContents, kTestString);
    expect(byteCount, kTestString.length);
  });
}
