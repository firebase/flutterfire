import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:e2e/e2e.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Find text in image', (WidgetTester tester) async {
//    final String tmpFilename = await _loadImage('assets/test_text.png');
//    final FirebaseVisionImage visionImage =
//        FirebaseVisionImage.fromFilePath(tmpFilename);
//
//    final VisionText text = await FirebaseVision.instance
//        .textRecognizer()
//        .processImage(visionImage);
//
//    expect(text.text, 'TEXT');
  });
}

// Since there is no way to get the full asset filename, this method loads the
// image into a temporary file.
Future<String> _loadImage(String assetFilename) async {
  final Directory directory = await getTemporaryDirectory();

  final String tmpFilename = path.join(
    directory.path,
    "tmp.jpg",
  );

  final ByteData data = await rootBundle.load(assetFilename);
  final Uint8List bytes = data.buffer.asUint8List(
    data.offsetInBytes,
    data.lengthInBytes,
  );

  await File(tmpFilename).writeAsBytes(bytes);

  return tmpFilename;
}
