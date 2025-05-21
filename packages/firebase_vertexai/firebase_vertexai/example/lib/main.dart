// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';

// Import after file is generated through flutterfire_cli.
// import 'package:vertex_ai_example/firebase_options.dart';

import 'pages/chat_page.dart';
import 'pages/audio_page.dart';
import 'pages/function_calling_page.dart';
import 'pages/image_prompt_page.dart';
import 'pages/token_count_page.dart';
import 'pages/schema_page.dart';
import 'pages/imagen_page.dart';
import 'pages/document.dart';
import 'pages/video_page.dart';
import 'pages/bidi_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Enable this line instead once have the firebase_options.dart generated and
  // imported through flutterfire_cli.
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Firebase.initializeApp();
  await FirebaseAuth.instance.signInAnonymously();
  runApp(const GenerativeAISample());
}

class GenerativeAISample extends StatefulWidget {
  const GenerativeAISample({super.key});

  @override
  State<GenerativeAISample> createState() => _GenerativeAISampleState();
}

class _GenerativeAISampleState extends State<GenerativeAISample> {
  bool _useVertexBackend = false;
  late GenerativeModel _currentModel;
  late ImagenModel _currentImagenModel;
  int _currentBottomNavIndex = 0;

  @override
  void initState() {
    super.initState();

    _initializeModel(_useVertexBackend);
  }

  void _initializeModel(bool useVertexBackend) {
    var generationConfig = ImagenGenerationConfig(
      negativePrompt: 'frog',
      numberOfImages: 1,
      aspectRatio: ImagenAspectRatio.square1x1,
      imageFormat: ImagenFormat.jpeg(compressionQuality: 75),
    );
    if (useVertexBackend) {
      final vertexInstance =
          // ignore: deprecated_member_use
          FirebaseVertexAI.instanceFor(auth: FirebaseAuth.instance);
      _currentModel = vertexInstance.generativeModel(model: 'gemini-1.5-flash');
      _currentImagenModel = vertexInstance.imagenModel(
        model: 'imagen-3.0-generate-001',
        generationConfig: generationConfig,
        safetySettings: ImagenSafetySettings(
          ImagenSafetyFilterLevel.blockLowAndAbove,
          ImagenPersonFilterLevel.allowAdult,
        ),
      );
    } else {
      final googleAI = FirebaseAI.googleAI(auth: FirebaseAuth.instance);
      _currentModel = googleAI.generativeModel(model: 'gemini-2.0-flash');
      _currentImagenModel = googleAI.imagenModel(
        model: 'imagen-3.0-generate-001',
        generationConfig: generationConfig,
        safetySettings: ImagenSafetySettings(
          ImagenSafetyFilterLevel.blockLowAndAbove,
          ImagenPersonFilterLevel.allowAdult,
        ),
      );
    }
  }

  void _toggleBackend(bool value) {
    setState(() {
      _useVertexBackend = value;
    });
    _initializeModel(_useVertexBackend);
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentBottomNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter + ${_useVertexBackend ? 'Vertex AI' : 'Google AI'}',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color.fromARGB(255, 171, 222, 244),
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(
        key: ValueKey(
          '${_useVertexBackend}_${_currentModel.hashCode}',
        ),
        model: _currentModel,
        imagenModel: _currentImagenModel,
        useVertexBackend: _useVertexBackend,
        onBackendChanged: _toggleBackend,
        selectedIndex: _currentBottomNavIndex,
        onSelectedIndexChanged: _onBottomNavTapped,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final GenerativeModel model;
  final ImagenModel imagenModel;
  final bool useVertexBackend;
  final ValueChanged<bool> onBackendChanged;
  final int selectedIndex;
  final ValueChanged<int> onSelectedIndexChanged;

  const HomeScreen({
    super.key,
    required this.model,
    required this.imagenModel,
    required this.useVertexBackend,
    required this.onBackendChanged,
    required this.selectedIndex,
    required this.onSelectedIndexChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _onItemTapped(int index) {
    widget.onSelectedIndexChanged(index);
  }

// Method to build the selected page on demand
  Widget _buildSelectedPage(
    int index,
    GenerativeModel currentModel,
    ImagenModel currentImagenModel,
    bool useVertexBackend,
  ) {
    switch (index) {
      case 0:
        return ChatPage(title: 'Chat', model: currentModel);
      case 1:
        return AudioPage(title: 'Audio', model: currentModel);
      case 2:
        return TokenCountPage(title: 'Token Count', model: currentModel);
      case 3:
        // FunctionCallingPage initializes its own model as per original design
        return FunctionCallingPage(
          title: 'Function Calling',
          useVertexBackend: useVertexBackend,
        );
      case 4:
        return ImagePromptPage(title: 'Image Prompt', model: currentModel);
      case 5:
        return ImagenPage(title: 'Imagen Model', model: currentImagenModel);
      case 6:
        return SchemaPromptPage(title: 'Schema Prompt', model: currentModel);
      case 7:
        return DocumentPage(title: 'Document Prompt', model: currentModel);
      case 8:
        return VideoPage(title: 'Video Prompt', model: currentModel);
      case 9:
        return BidiPage(title: 'Bidi Stream', model: currentModel);
      default:
        // Fallback to the first page in case of an unexpected index
        return ChatPage(title: 'Chat', model: currentModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Flutter + ${widget.useVertexBackend ? 'Vertex AI' : 'Google AI'}',
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Google AI',
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.useVertexBackend
                        ? Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7)
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                Switch(
                  value: widget.useVertexBackend,
                  onChanged: widget.onBackendChanged,
                  activeTrackColor: Colors.green.withValues(alpha: 0.5),
                  inactiveTrackColor: Colors.blueGrey.withValues(alpha: 0.5),
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.blueGrey,
                ),
                Text(
                  'Vertex AI',
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.useVertexBackend
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: _buildSelectedPage(
          widget.selectedIndex,
          widget.model,
          widget.imagenModel,
          widget.useVertexBackend,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 10,
        unselectedFontSize: 9,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor:
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
            tooltip: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: 'Audio',
            tooltip: 'Audio Prompt',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.numbers),
            label: 'Tokens',
            tooltip: 'Token Count',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.functions),
            label: 'Functions',
            tooltip: 'Function Calling',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'Image',
            tooltip: 'Image Prompt',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image_search),
            label: 'Imagen',
            tooltip: 'Imagen Model',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schema),
            label: 'Schema',
            tooltip: 'Schema Prompt',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_document),
            label: 'Document',
            tooltip: 'Document Prompt',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_collection),
            label: 'Video',
            tooltip: 'Video Prompt',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.stream),
            label: 'Bidi',
            tooltip: 'Bidi Stream',
          ),
        ],
        currentIndex: widget.selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
