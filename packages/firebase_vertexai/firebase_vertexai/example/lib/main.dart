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
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';

import 'pages/chat_page.dart';
import 'pages/function_calling_page.dart';
import 'pages/image_prompt_page.dart';
import 'pages/token_count_page.dart';
import 'pages/schema_page.dart';
import 'pages/imagen_page.dart';

// REQUIRED if you want to run on Web
const FirebaseOptions? options = null;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.signInAnonymously();

  var vertex_instance =
      FirebaseVertexAI.instanceFor(auth: FirebaseAuth.instance);
  final model = vertex_instance.generativeModel(model: 'gemini-1.5-flash');

  runApp(GenerativeAISample(model: model));
}

class GenerativeAISample extends StatelessWidget {
  final GenerativeModel model;

  const GenerativeAISample({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter + Vertex AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color.fromARGB(255, 171, 222, 244),
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(model: model),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final GenerativeModel model;
  const HomeScreen({super.key, required this.model});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Widget> get _pages => <Widget>[
        // Build _pages dynamically
        ChatPage(title: 'Chat', model: widget.model),
        TokenCountPage(title: 'Token Count', model: widget.model),
        const FunctionCallingPage(
          title: 'Function Calling',
        ), // function calling will initial its own model
        ImagePromptPage(title: 'Image Prompt', model: widget.model),
        ImagenPage(title: 'Imagen Model', model: widget.model),
        SchemaPromptPage(title: 'Schema Prompt', model: widget.model),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter + Vertex AI'),
      ),
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.chat,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Chat',
            tooltip: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.numbers,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Token Count',
            tooltip: 'Token Count',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.functions,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Function Calling',
            tooltip: 'Function Calling',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.image,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Image Prompt',
            tooltip: 'Image Prompt',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.image_search,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Imagen Model',
            tooltip: 'Imagen Model',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.schema,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Schema Prompt',
            tooltip: 'Schema Prompt',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
