// Copyright 2025 Google LLC
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

import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import '../widgets/message_widget.dart';

class ImagenPage extends StatefulWidget {
  const ImagenPage({
    super.key,
    required this.title,
    required this.model,
  });

  final String title;
  final ImagenModel model;

  @override
  State<ImagenPage> createState() => _ImagenPageState();
}

class _ImagenPageState extends State<ImagenPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  final List<MessageData> _generatedContent = <MessageData>[];
  bool _loading = false;

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(
          milliseconds: 750,
        ),
        curve: Curves.easeOutCirc,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemBuilder: (context, idx) {
                  return MessageWidget(
                    text: _generatedContent[idx].text,
                    image: _generatedContent[idx].image,
                    isFromUser: _generatedContent[idx].fromUser ?? false,
                  );
                },
                itemCount: _generatedContent.length,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 25,
                horizontal: 15,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      focusNode: _textFieldFocus,
                      controller: _textController,
                    ),
                  ),
                  const SizedBox.square(
                    dimension: 15,
                  ),
                  if (!_loading)
                    IconButton(
                      onPressed: () async {
                        await _testImagen(_textController.text);
                      },
                      icon: Icon(
                        Icons.image_search,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      tooltip: 'Imagen raw data',
                    )
                  else
                    const CircularProgressIndicator(),
                  // NOTE: Keep this API private until future release.
                  // if (!_loading)
                  //   IconButton(
                  //     onPressed: () async {
                  //       await _testImagenGCS(_textController.text);
                  //     },
                  //     icon: Icon(
                  //       Icons.imagesearch_roller,
                  //       color: Theme.of(context).colorScheme.primary,
                  //     ),
                  //     tooltip: 'Imagen GCS',
                  //   )
                  // else
                  //   const CircularProgressIndicator(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testImagen(String prompt) async {
    setState(() {
      _loading = true;
    });

    try {
      var response = await widget.model.generateImages(prompt);

      if (response.images.isNotEmpty) {
        var imagenImage = response.images[0];

        _generatedContent.add(
          MessageData(
            image: Image.memory(imagenImage.bytesBase64Encoded),
            text: prompt,
            fromUser: false,
          ),
        );
      } else {
        // Handle the case where no images were generated
        _showError('Error: No images were generated.');
      }
    } catch (e) {
      _showError(e.toString());
    }

    setState(() {
      _loading = false;
      _scrollDown();
    });
  }
  // NOTE: Keep this API private until future release.
  // Future<void> _testImagenGCS(String prompt) async {
  //   setState(() {
  //     _loading = true;
  //   });
  //   var gcsUrl = 'gs://vertex-ai-example-ef5a2.appspot.com/imagen';

  //   var response = await widget.model.generateImagesGCS(prompt, gcsUrl);

  //   if (response.images.isNotEmpty) {
  //     var imagenImage = response.images[0];
  //     final returnImageUri = imagenImage.gcsUri;
  //     final reference = FirebaseStorage.instance.refFromURL(returnImageUri);
  //     final downloadUrl = await reference.getDownloadURL();
  //     // Process the image
  //     _generatedContent.add(
  //       MessageData(
  //         image: Image(image: NetworkImage(downloadUrl)),
  //         text: prompt,
  //         fromUser: false,
  //       ),
  //     );
  //   } else {
  //     // Handle the case where no images were generated
  //     _showError('Error: No images were generated.');
  //   }
  //   setState(() {
  //     _loading = false;
  //   });
  // }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Something went wrong'),
          content: SingleChildScrollView(
            child: SelectableText(message),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
