import 'package:firebase/firebase.dart' as fb;

import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:firebase_storage_web/firebase_storage_web.dart';
import 'package:mockito/mockito.dart';
import 'package:test/fake.dart';

class FakeRef extends Fake implements ReferencePlatform {}

class MockRef extends Mock implements fb.StorageReference {}

class MockStorageWeb extends Mock implements FirebaseStorageWeb {}

class MockFbStorage extends Mock implements fb.Storage {}

class MockFullMetadata extends Mock implements fb.FullMetadata {}

class MockUploadTask extends Mock implements fb.UploadTask {}

class MockUploadTaskSnapshot extends Mock implements fb.UploadTaskSnapshot {}

class MockListResults extends Mock implements fb.ListResult {}
