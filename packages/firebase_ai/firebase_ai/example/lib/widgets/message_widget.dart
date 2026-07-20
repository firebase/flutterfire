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
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MessageData {
  MessageData({
    this.imageBytes,
    this.text,
    this.fromUser,
    this.isThought = false,
  });

  MessageData copyWith({
    Uint8List? imageBytes,
    String? text,
    bool? fromUser,
    bool? isThought,
  }) {
    return MessageData(
      imageBytes: imageBytes ?? this.imageBytes,
      text: text ?? this.text,
      fromUser: fromUser ?? this.fromUser,
      isThought: isThought ?? this.isThought,
    );
  }

  final Uint8List? imageBytes;
  final String? text;
  final bool? fromUser;
  final bool isThought;
}

class MessageWidget extends StatelessWidget {
  final Image? image;
  final String? text;
  final bool isFromUser;
  final bool isThought;

  const MessageWidget({
    super.key,
    this.image,
    this.text,
    required this.isFromUser,
    this.isThought = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            decoration: BoxDecoration(
              color: isThought
                  ? Theme.of(context).colorScheme.secondaryContainer
                  : isFromUser
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 20,
            ),
            margin: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                if (text case final text?) MarkdownBody(data: text),
                if (image case final image?) image,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
