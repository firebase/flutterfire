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
import '../utils/image_utils.dart';

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
                    image: Image.memory(
                      _generatedContent[idx].imageBytes!,
                      cacheWidth: 400,
                      cacheHeight: 400,
                    ),
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
                          await _editWithMask();
                        },
                        icon: Icon(
                          Icons.brush,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        tooltip: 'Edit with Mask',
                      ),
                      IconButton(
                        onPressed: () async {
                          await _editWithStyle();
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        tooltip: 'Edit with Style',
                      ),
                      IconButton(
                        onPressed: () async {
                          await _outpaintImage();
                        },
                        icon: Icon(
                          Icons.masks,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        tooltip: 'Outpaint',
                      ),
                      IconButton(
                        onPressed: () async {
                          await _inpaintImageHappyPath();
                        },
                        icon: Icon(
                          Icons.plus_one,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        tooltip: 'Inpaint',
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
          bytesBase64Encoded: imageBytes,
          mimeType: mimeType,
        );
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

  Future<void> _inpaintImageHappyPath() async {
    if (_sourceImage == null) {
      _showError('Please pick a source image for inpaint insertion.');
      return;
    }
    setState(() {
      _loading = true;
    });

    final String prompt = _textController.text;
    final promptMessage = MessageData(
      imageBytes: _sourceImage!.bytesBase64Encoded,
      text: 'Try to inpaint image with prompt: $prompt',
      fromUser: true,
    );

    MessageData? resultMessage;

    try {
      final response = await widget.model.inpaintImage(
        _sourceImage!,
        prompt,
        ImagenBackgroundMask(),
        config: ImagenEditingConfig(editMode: ImagenEditMode.inpaintInsertion),
      );
      if (response.images.isNotEmpty) {
        final inpaintImage = response.images[0];
        resultMessage = MessageData(
          imageBytes: inpaintImage.bytesBase64Encoded,
          text: 'Inpaint image result with prompt: $prompt',
          fromUser: false,
        );
      } else {
        _showError('No image was returned from inpaint.');
      }
    } catch (e) {
      _showError('Error inpaint image: $e');
    }

    setState(() {
      _generatedContent.add(promptMessage);
      if (resultMessage != null) {
        _generatedContent.add(resultMessage);
      }
      _loading = false;
      _scrollDown();
    });
  }

  Future<void> _editWithMask() async {
    if (_sourceImage == null) {
      _showError('Please pick a source image for editing.');
      return;
    }
    if (_maskImageForEditing == null) {
      _showError('Please pick a mask image for editing.');
      return;
    }

    setState(() {
      _loading = true;
    });

    final String prompt = _textController.text;
    // Create a message to show what we are doing
    final promptMessage = MessageData(
      imageBytes: _sourceImage!.bytesBase64Encoded,
      text: 'Editing image with mask and prompt: $prompt',
      fromUser: true,
    );

    MessageData? resultMessage;

    try {
      final response = await widget.model.editImage(
        [
          ImagenRawImage(image: _sourceImage!),
          ImagenRawMask(mask: _maskImageForEditing!),
        ],
        prompt,
      );

      if (response.images.isNotEmpty) {
        final editedImage = response.images[0];
        resultMessage = MessageData(
          imageBytes: editedImage.bytesBase64Encoded,
          text: 'Edited image result with prompt: $prompt',
          fromUser: false,
        );
      } else {
        _showError('No image was returned from editing with mask.');
      }
    } catch (e) {
      _showError('Error editing image with mask: $e');
    }

    setState(() {
      _generatedContent.add(promptMessage);
      if (resultMessage != null) {
        _generatedContent.add(resultMessage);
      }
      _loading = false;
      _scrollDown();
    });
  }

  Future<void> _outpaintImage() async {
    if (_sourceImage == null) {
      _showError('Please pick a source image for outpainting.');
      return;
    }
    setState(() {
      _loading = true;
    });

    final promptMessage = MessageData(
      imageBytes: _sourceImage!.bytesBase64Encoded,
      text: 'Outpaint the picture to 1400*1400',
      fromUser: true,
    );

    MessageData? resultMessage;
    try {
      final referenceImages = await generateMaskAndPadForOutpainting(
        image: _sourceImage!,
        newDimensions: ImagenDimensions(width: 1400, height: 1400),
      );
      final response = await widget.model.editImage(
        referenceImages,
        '',
        config: ImagenEditingConfig(editMode: ImagenEditMode.outpaint),
      );
      if (response.images.isNotEmpty) {
        final editedImage = response.images[0];
        resultMessage = MessageData(
          imageBytes: editedImage.bytesBase64Encoded,
          text: 'Edited image Outpaint 1400*1400',
          fromUser: false,
        );
      } else {
        _showError('No image was returned from editing.');
      }
    } catch (e) {
      _showError('Error editing image: $e');
    }

    setState(() {
      _generatedContent.add(promptMessage);
      if (resultMessage != null) {
        _generatedContent.add(resultMessage);
      }
      _loading = false;
      _scrollDown();
    });
  }

  Future<void> _editWithStyle() async {
    if (_sourceImage == null) {
      _showError('Please pick a source image for style editing.');
      return;
    }
    setState(() {
      _loading = true;
    });

    final String prompt = _textController.text;
    final promptMessage = MessageData(
      imageBytes: _sourceImage!.bytesBase64Encoded,
      text: prompt,
      fromUser: true,
    );
    MessageData? resultMessage;
    try {
      final response = await widget.model.editImage(
        [
          ImagenStyleReference(
            image: _sourceImage!,
            description: 'van goh style',
            referenceId: 1,
          ),
        ],
        prompt,
        config: ImagenEditingConfig(editSteps: 50),
      );
      if (response.images.isNotEmpty) {
        final editedImage = response.images[0];

        resultMessage = MessageData(
          imageBytes: editedImage.bytesBase64Encoded,
          text: 'Edited image with style: $prompt',
          fromUser: false,
        );
      } else {
        _showError('No image was returned from style editing.');
      }
    } catch (e) {
      _showError('Error performing style edit: $e');
    }

    setState(() {
      _generatedContent.add(promptMessage);
      if (resultMessage != null) {
        _generatedContent.add(resultMessage);
      }

      _loading = false;
      _scrollDown();
    });
  }

  Future<void> _generateImageFromPrompt(String prompt) async {
    setState(() {
      _loading = true;
    });
    MessageData? resultMessage;
    try {
      var response = await widget.model.generateImages(prompt);

      if (response.images.isNotEmpty) {
        var imagenImage = response.images[0];

        resultMessage = MessageData(
          imageBytes: imagenImage.bytesBase64Encoded,
          text: prompt,
          fromUser: false,
        );
      } else {
        // Handle the case where no images were generated
        _showError('Error: No images were generated.');
      }
    } catch (e) {
      _showError(e.toString());
    }

    setState(() {
      if (resultMessage != null) {
        _generatedContent.add(resultMessage);
      }

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
