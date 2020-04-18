part of test_suites;

Firestore sharedFirestoreInstance;

void setupCloudFirestoreTests() {
  setUp(() async {
    sharedFirestoreInstance = Firestore(app: sharedFirebaseAppInstance);
  });

  testWidgets('sets document data', (WidgetTester tester) async {
    Map<String, dynamic> data = {"flutter": "fire", "bar": 2};
    DocumentReference document = sharedFirestoreInstance
        .collection("flutter-tests")
        .document("test-document");

    await document.delete();
    DocumentSnapshot snapshotBeforeSet = await document.get();

    expect(snapshotBeforeSet.data, null,
        reason: "Document snapshot data should be null after deleting it.");

    await document.setData(data);
    DocumentSnapshot snapshotAfterGet = await document.get();

    expect(snapshotAfterGet.data, data,
        reason: "Document snapshot data did not match original data payload.");

//    await Future.delayed(const Duration(seconds: 61), () => "1");
  });
}
