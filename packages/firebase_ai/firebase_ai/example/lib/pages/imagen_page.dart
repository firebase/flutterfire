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

import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_ai/firebase_ai.dart';

import 'package:flutter/material.dart';
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

  // For image picking
  ImagenInlineImage? _sourceImage;
  ImagenInlineImage? _maskImageForEditing;

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
              child: Column(
                children: [
                  // Generate Image Row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          autofocus: true,
                          focusNode: _textFieldFocus,
                          decoration: const InputDecoration(
                            hintText: 'Enter a prompt...',
                          ),
                          controller: _textController,
                        ),
                      ),
                      const SizedBox.square(dimension: 15),
                      IconButton(
                        onPressed: () async {
                          await _pickSourceImage();
                        },
                        icon: Icon(
                          Icons.add_a_photo,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        tooltip: 'Pick Source Image',
                      ),
                      IconButton(
                        onPressed: () async {
                          await _pickMaskImage();
                        },
                        icon: Icon(
                          Icons.add_to_photos,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        tooltip: 'Pick mask',
                      ),
                      IconButton(
                        onPressed: () async {
                          await _editImageMaskFree();
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        tooltip: 'Edit Image Mask Free',
                      ),
                      IconButton(
                        onPressed: () async {
                          await _editImageInpaintOutpaint();
                        },
                        icon: Icon(
                          Icons.masks,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        tooltip: 'Mask Inpaint Outpaint',
                      ),
                      IconButton(
                        onPressed: () async {
                          await _upscaleImage();
                        },
                        icon: Icon(
                          Icons.plus_one,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        tooltip: 'Upscale',
                      ),
                      if (!_loading)
                        IconButton(
                          onPressed: () async {
                            await _generateImageFromPrompt(
                              _textController.text,
                            );
                          },
                          icon: Icon(
                            Icons.image_search,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          tooltip: 'Generate Image',
                        )
                      else
                        const CircularProgressIndicator(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<ImagenInlineImage?> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? imageFile =
          await picker.pickImage(source: ImageSource.gallery);
      if (imageFile != null) {
        // Attempt to get mimeType, default if null.
        // Note: imageFile.mimeType might be null on some platforms or for some files.
        final String mimeType = imageFile.mimeType ?? 'image/jpeg';
        final Uint8List imageBytes = await imageFile.readAsBytes();
        return ImagenInlineImage(
            bytesBase64Encoded: imageBytes, mimeType: mimeType);
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
    return null;
  }

  Future<void> _pickSourceImage() async {
    final pickedImage = await _pickImage();
    if (pickedImage != null) {
      setState(() {
        _sourceImage = pickedImage;
      });
    }
  }

  Future<void> _pickMaskImage() async {
    final pickedImage = await _pickImage();
    if (pickedImage != null) {
      setState(() {
        _maskImageForEditing = pickedImage;
      });
    }
  }

  Future<void> _upscaleImage() async {
    if (_sourceImage == null) {
      _showError('Please pick a source image for upscaling.');
      return;
    }
    setState(() {
      _loading = true;
    });

    setState(() {
      _generatedContent.add(
        MessageData(
          image: Image.memory(_sourceImage!.bytesBase64Encoded),
          text:
              'Try to Upscaled image (Factor: ${ImagenUpscaleFactor.x2.name})',
          fromUser: true,
        ),
      );
      _scrollDown();
    });

    try {
      final response = await widget.model.upscaleImage(
        image: _sourceImage!,
        upscaleFactor: ImagenUpscaleFactor.x2,
      );
      if (response.images.isNotEmpty) {
        final upscaledImage = response.images[0];
        setState(() {
          _generatedContent.add(
            MessageData(
              image: Image.memory(upscaledImage.bytesBase64Encoded),
              text: 'Upscaled image (Factor: ${ImagenUpscaleFactor.x2.name})',
              fromUser: false,
            ),
          );
          _scrollDown();
        });
      } else {
        _showError('No image was returned from upscaling.');
      }
    } catch (e) {
      _showError('Error upscaling image: $e');
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _editImageInpaintOutpaint() async {
    if (_sourceImage == null || _maskImageForEditing == null) {
      _showError(
          'Please pick a source image and a mask image for inpainting/outpainting.');
      return;
    }
    setState(() {
      _loading = true;
    });

    final String prompt = _textController.text;

    setState(() {
      _generatedContent.add(
        MessageData(
          image: Image.memory(_sourceImage!.bytesBase64Encoded),
          text: prompt,
          fromUser: true,
        ),
      );
      _scrollDown();
    });

    final editConfig = ImagenEditingConfig(
      image: _sourceImage!,
      mask: _maskImageForEditing,
      maskDilation: 0.01,
      editSteps: 50,
    );

    try {
      final response = await widget.model.editImage(
        prompt,
        config: editConfig,
      );
      if (response.images.isNotEmpty) {
        final editedImage = response.images[0];
        setState(() {
          _generatedContent.add(
            MessageData(
              image: Image.memory(editedImage.bytesBase64Encoded),
              text: 'Edited image (Inpaint/Outpaint): $prompt',
              fromUser: false,
            ),
          );
          _scrollDown();
        });
      } else {
        _showError('No image was returned from editing.');
      }
    } catch (e) {
      _showError('Error editing image: $e');
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _editImageMaskFree() async {
    if (_sourceImage == null) {
      _showError('Please pick a source image for mask-free editing.');
      return;
    }
    setState(() {
      _loading = true;
    });

    final String prompt = _textController.text;

    setState(() {
      _generatedContent.add(
        MessageData(
          image: Image.memory(_sourceImage!.bytesBase64Encoded),
          text: prompt,
          fromUser: true,
        ),
      );
      _scrollDown();
    });
    final editConfig = ImagenEditingConfig.maskFree(
      image: _sourceImage!,
      // numberOfImages: 1, // Default in model or could be added to UI
    );

    try {
      final response = await widget.model.editImage(
        prompt,
        config: editConfig,
      );
      if (response.images.isNotEmpty) {
        final editedImage = response.images[0];
        setState(() {
          _generatedContent.add(
            MessageData(
              image: Image.memory(editedImage.bytesBase64Encoded),
              text: 'Edited image (Mask-Free): $prompt',
              fromUser: false,
            ),
          );
          _scrollDown();
        });
      } else {
        _showError('No image was returned from mask-free editing.');
      }
    } catch (e) {
      _showError('Error performing mask-free edit: $e');
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _generateImageFromPrompt(String prompt) async {
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
