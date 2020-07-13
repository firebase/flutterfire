import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml/firebase_ml.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(
    MaterialApp(
      home: MyApp(),
    ),
  );
}

/// Widget with a future function that initiates actions from FirebaseML
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final picker = ImagePicker();
  File _image;
  List<Map<dynamic, dynamic>> _labels;
  Future<String> _loaded = loadModel();

  Future<void> getImageLabels() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    final image = File(pickedFile.path);
    if (image == null) {
      return;
    }
    var labels = List<Map>.from(await Tflite.runModelOnImage(
      path: image.path,
    ));
    setState(() {
      _labels = labels;
      _image = image;
    });
  }

  static Future<String> loadModel() async {
    var modelFile = await loadModelFromFirebase();
    return await loadTFLiteModel(modelFile);
  }

  static Future<File> loadModelFromFirebase() async {
    var model = FirebaseCustomRemoteModel('image_classification');

    var conditions = FirebaseModelDownloadConditions(requireWifi: true);
    var modelManager = FirebaseModelManager.instance;

    await modelManager.download(model, conditions);
    assert(await modelManager.isModelDownloaded(model) == true);

    var modelFile = await modelManager.getLatestModelFile(model);
    assert(modelFile != null);
    return modelFile;
  }

  static Future<String> loadTFLiteModel(File modelFile) async {
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
    return "Model is loaded";
  }

  Widget readyScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase ML example app'),
      ),
      body: Column(
        children: [
          _image != null
              ? Image.file(_image)
              : Text('Please select image to analyze.'),
          Column(
            children: _labels != null
                ? _labels.map((label) {
                    return Text("${label["label"]}");
                  }).toList()
                : [],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImageLabels,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget errorScreen() {
    return Scaffold(
      body: Center(
        child: Text("Error loading model. Sorry about that :("),
      ),
    );
  }

  Widget loadingScreen() {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.headline2,
      textAlign: TextAlign.center,
      child: FutureBuilder<String>(
        future: _loaded, // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return readyScreen();
          } else if (snapshot.hasError) {
            return errorScreen();
          } else {
            return loadingScreen();
          }
        },
      ),
    );
  }
}
