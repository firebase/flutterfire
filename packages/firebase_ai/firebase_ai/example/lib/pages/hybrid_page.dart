// Copyright 2026 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';

class HybridPage extends StatefulWidget {
  final String title;
  final GenerativeModel model;

  const HybridPage({super.key, required this.title, required this.model});

  @override
  State<HybridPage> createState() => _HybridPageState();
}

class _HybridPageState extends State<HybridPage> {
  late HybridGenerativeModel _hybridModel;
  InferenceMode _selectedMode = InferenceMode.preferCloud;
  final TextEditingController _promptController = TextEditingController();
  String _response = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _hybridModel = HybridGenerativeModel(
      cloudModel: widget.model,
      mode: _selectedMode,
    );
  }

  void _updateMode(InferenceMode? newMode) {
    if (newMode != null) {
      setState(() {
        _selectedMode = newMode;
        _hybridModel = HybridGenerativeModel(
          cloudModel: widget.model,
          mode: _selectedMode,
        );
      });
    }
  }

  Future<void> _generate() async {
    setState(() {
      _isLoading = true;
      _response = '';
    });
    try {
      final response = await _hybridModel.generateContent([Content.text(_promptController.text)]);
      setState(() {
        _response = response.text ?? 'No response';
      });
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _stream() {
    setState(() {
      _isLoading = true;
      _response = '';
    });
    
    _hybridModel.generateContentStream([Content.text(_promptController.text)]).listen(
      (response) {
        setState(() {
          _response += response.text ?? '';
        });
      },
      onError: (e) {
        setState(() {
          _response += '\nError: $e';
          _isLoading = false;
        });
      },
      onDone: () {
        setState(() {
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _warmup() async {
    setState(() {
      _isLoading = true;
      _response = 'Warming up...';
    });
    try {
      await _hybridModel.warmup();
      setState(() {
        _response = 'Warmup completed!';
      });
    } catch (e) {
      setState(() {
        _response = 'Warmup failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<InferenceMode>(
              value: _selectedMode,
              onChanged: _updateMode,
              items: InferenceMode.values.map((mode) {
                return DropdownMenuItem(
                  value: mode,
                  child: Text(mode.toString().split('.').last),
                );
              }).toList(),
            ),
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(labelText: 'Prompt'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _generate,
                  child: const Text('Generate'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _stream,
                  child: const Text('Stream'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _warmup,
                  child: const Text('Warmup'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading) const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_response),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
