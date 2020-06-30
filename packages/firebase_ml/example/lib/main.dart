import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml/firebase_ml.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

/// Widget with a future function that initiates actions from FirebaseML
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final picker = ImagePicker();
  File _image;
  List _labels;

  Future<void> getImageLabels() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    final image = File(pickedFile.path);
    if (image != null) {
      var labels = await Tflite.runModelOnImage(
        path: image.path,
      );
      setState(() {
        _labels = labels;
        _image = image;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadModelFromFirebase();
  }

  Future<void> loadModelFromFirebase() async {
    FirebaseCustomRemoteModel model =
        FirebaseCustomRemoteModel('image_classification');

    FirebaseModelDownloadConditions conditions =
        FirebaseModelDownloadConditions(requireWifi: true);
    FirebaseModelManager modelManager = FirebaseModelManager.instance;

    await modelManager.download(model, conditions);

    var isModelDownloaded = await modelManager.isModelDownloaded(model);
    assert(isModelDownloaded == true);

    var modelFile = await modelManager.getLatestModelFile(model);
    assert(modelFile != null);

    var appDirectory = await getApplicationDocumentsDirectory();
    var labelsData =
        await rootBundle.load("assets/labels_mobilenet_v1_224.txt");
    var labelsFile =
        await File(appDirectory.path + "_labels_mobilenet_v1_224.txt")
            .writeAsBytes(labelsData.buffer.asUint8List(
                labelsData.offsetInBytes, labelsData.lengthInBytes));

    assert(await Tflite.loadModel(
          model: modelFile.path,
          labels: labelsFile.path,
          isAsset: false,
        ) ==
        "success");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FirebaseML example app'),
        ),
        body: Column(children: [
          _image != null
              ? Image.file(_image)
              : Text('Please select image to analyze.'),
          Column(
            children: _labels != null
                ? _labels.map((res) {
                    return Text("${res["label"]}");
                  }).toList()
                : [],
          ),
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: getImageLabels,
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
