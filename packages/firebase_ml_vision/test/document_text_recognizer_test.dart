// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

import 'dart:ui';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$FirebaseVision', () {
    final List<MethodCall> log = <MethodCall>[];
    dynamic returnValue;

    setUp(() {
      FirebaseVision.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);

        switch (methodCall.method) {
          case 'DocumentTextRecognizer#processImage':
            return returnValue;
          case 'DocumentTextRecognizer#close':
            return null;
          default:
            throw UnimplementedError();
        }
      });
      log.clear();
      FirebaseVision.nextHandle = 0;
    });

    group('$DocumentTextRecognizer', () {
      DocumentTextRecognizer recognizer;
      final FirebaseVisionImage image = FirebaseVisionImage.fromFilePath(
        'empty',
      );

      setUp(() {
        recognizer = FirebaseVision.instance.cloudDocumentTextRecognizer();
        returnValue = <dynamic, dynamic>{
          'text': 'Hello',
          'blocks': <dynamic>[],
        };
      });

      group('successfully calls native API to', () {
        test('process an image with default options', () async {
          final text = await recognizer.processImage(image);

          expect(text.text, 'Hello');
          expect(log, <Matcher>[
            isMethodCall(
              'DocumentTextRecognizer#processImage',
              arguments: <String, dynamic>{
                'handle': 0,
                'options': <String, dynamic>{'hintedLanguages': null},
                'type': 'file',
                'path': 'empty',
                'bytes': null,
                'metadata': null,
              },
            ),
          ]);
        });

        test('process an image with non-default options', () async {
          final hintedLanguages = ['en', 'ru'];
          final options =
              CloudDocumentRecognizerOptions(hintedLanguages: hintedLanguages);
          final recognizerWithOptions =
              FirebaseVision.instance.cloudDocumentTextRecognizer(options);
          final text = await recognizerWithOptions.processImage(image);

          expect(text.text, 'Hello');
          expect(log, <Matcher>[
            isMethodCall(
              'DocumentTextRecognizer#processImage',
              arguments: <String, dynamic>{
                'handle': 1,
                'options': <String, dynamic>{
                  'hintedLanguages': ['en', 'ru']
                },
                'type': 'file',
                'path': 'empty',
                'bytes': null,
                'metadata': null,
              },
            ),
          ]);
        });

        test('close', () async {
          await recognizer.processImage(image);
          expect(recognizer.close(), completes);

          expect(log, <Matcher>[
            isMethodCall(
              'DocumentTextRecognizer#processImage',
              arguments: <String, dynamic>{
                'handle': 0,
                'options': <String, dynamic>{'hintedLanguages': null},
                'type': 'file',
                'path': 'empty',
                'bytes': null,
                'metadata': null,
              },
            ),
            isMethodCall(
              'DocumentTextRecognizer#close',
              arguments: <String, dynamic>{
                'handle': 0,
              },
            ),
          ]);
        });
      });

      test('when called to close without opening returns right away', () async {
        expect(recognizer.close(), completes);

        expect(log, <Matcher>[]);
      });

      test('when given wrong input on processing an image fails', () async {
        expect(
            () => recognizer.processImage(null),
            throwsA(isA<AssertionError>().having((e) => e.toString(), 'message',
                contains("'visionImage != null': is not true"))));
      });

      group('throws an exception when native API fails to', () {
        const errorMessage = 'There is some problem with a call';

        test('process an image', () async {
          FirebaseVision.channel
              .setMockMethodCallHandler((MethodCall methodCall) async {
            throw Exception(errorMessage);
          });
          expect(
              recognizer.processImage(image),
              throwsA(isA<PlatformException>().having(
                  (e) => e.toString(), 'message', contains(errorMessage))));
        });

        test('close', () async {
          FirebaseVision.channel
              .setMockMethodCallHandler((MethodCall methodCall) async {
            switch (methodCall.method) {
              case 'DocumentTextRecognizer#processImage':
                return returnValue;
              default:
                throw Exception(errorMessage);
            }
          });
          await recognizer.processImage(image);

          expect(
              recognizer.close(),
              throwsA(isA<PlatformException>().having(
                  (e) => e.toString(), 'message', contains(errorMessage))));
        });
      });

      group('successfully processes an image', () {
        setUp(() {
          final List<dynamic> symbols = <dynamic>[
            <dynamic, dynamic>{
              'recognizedLanguages': [
                {'languageCode': 'en'}
              ],
              'top': 1.0,
              'left': 2.0,
              'confidence': 1,
              'width': 3.0,
              'text': 'H',
              'recognizedBreak': null,
              'height': 4.0
            },
            <dynamic, dynamic>{
              'recognizedLanguages': [
                {'languageCode': 'hi'}
              ],
              'top': 5.0,
              'left': 6.0,
              'confidence': 0.95,
              'width': 7.0,
              'text': 'e',
              'recognizedBreak': null,
              'height': 8.0
            },
            <dynamic, dynamic>{
              'recognizedLanguages': [
                {'languageCode': 'fr'}
              ],
              'top': 9.0,
              'left': 10.0,
              'confidence': 0.85,
              'width': 11.0,
              'text': 'y',
              'recognizedBreak': null,
              'height': 12.0
            },
          ];
          final List<dynamic> words = <dynamic>[
            <dynamic, dynamic>{
              'recognizedLanguages': [
                {'languageCode': 'ru'}
              ],
              'top': 13.0,
              'left': 14.0,
              'confidence': 0,
              'width': 15.0,
              'text': 'Hey',
              'recognizedBreak': null,
              'symbols': symbols,
              'height': 16.0
            },
            <dynamic, dynamic>{
              'recognizedLanguages': [],
              'top': 17.0,
              'left': 18.0,
              'confidence': 0.1,
              'width': 19.0,
              'text': '!',
              'recognizedBreak': {
                'detectedBreakType': 5,
                'detectedBreakPrefix': false
              },
              'symbols': <dynamic>[],
              'height': 20.0
            },
          ];

          final List<dynamic> paragraphs = <dynamic>[
            <String, dynamic>{
              'recognizedLanguages': [
                {'languageCode': 'es'}
              ],
              'top': 21.0,
              'left': 22.0,
              'confidence': 0.5,
              'width': 23.0,
              'words': words,
              'text': 'Hey!',
              'recognizedBreak': {
                'detectedBreakType': 5,
                'detectedBreakPrefix': false
              },
              'height': 24.0
            },
          ];

          final List<dynamic> blocks = <dynamic>[
            <dynamic, dynamic>{
              'recognizedLanguages': [
                {'languageCode': 'it'}
              ],
              'top': 25.0,
              'left': 26.0,
              'confidence': 0.8,
              'width': 27.0,
              'text': 'Hey!',
              'paragraphs': paragraphs,
              'recognizedBreak': {
                'detectedBreakType': 5,
                'detectedBreakPrefix': false
              },
              'height': 28.0
            },
            <dynamic, dynamic>{
              'recognizedLanguages': <dynamic>[],
              'confidence': 1,
              'text': '',
              'recognizedBreak': {
                'detectedBreakType': 3,
                'detectedBreakPrefix': true
              },
              'paragraphs': <dynamic>[]
            },
          ];

          final dynamic visionText = <dynamic, dynamic>{
            'text': 'Hey!',
            'blocks': blocks,
          };

          returnValue = visionText;
        });

        group('$VisionDocumentText', () {
          test('is valid after a valid reply', () async {
            final VisionDocumentText text =
                await recognizer.processImage(image);
            expect(text.blocks, hasLength(2));
            expect(text.text, 'Hey!');
          });

          group('$DocumentTextBlock', () {
            test('is valid after a valid reply', () async {
              final VisionDocumentText text =
                  await recognizer.processImage(image);

              DocumentTextBlock block = text.blocks[0];
              // TODO(jackson): Use const Rect when available in minimum Flutter SDK
              // ignore: prefer_const_constructors
              expect(block.boundingBox, Rect.fromLTWH(26, 25, 27, 28));
              expect(block.text, 'Hey!');
              expect(block.recognizedBreak.detectedBreakType,
                  TextRecognizedBreakType.values[5]);
              expect(block.recognizedBreak.isPrefix, false);
              expect(block.recognizedLanguages, hasLength(1));
              expect(block.recognizedLanguages[0].languageCode, 'it');
              expect(block.confidence, 0.8);
              expect(block.paragraphs, hasLength(1));

              block = text.blocks[1];
              // TODO(jackson): Use const Rect when available in minimum Flutter SDK
              // ignore: prefer_const_constructors
              expect(block.boundingBox, isNull);
              expect(block.text, '');
              expect(block.recognizedBreak.detectedBreakType,
                  TextRecognizedBreakType.values[3]);
              expect(block.recognizedBreak.isPrefix, true);
              expect(block.recognizedLanguages, hasLength(0));
              expect(block.confidence, 1.0);
              expect(block.paragraphs, hasLength(0));
            });
          });

          group('$DocumentTextParagraph', () {
            test('is valid after a valid reply', () async {
              final VisionDocumentText text =
                  await recognizer.processImage(image);

              DocumentTextParagraph paragraph = text.blocks[0].paragraphs[0];
              // TODO(jackson): Use const Rect when available in minimum Flutter SDK
              // ignore: prefer_const_constructors
              expect(
                  paragraph.boundingBox, const Rect.fromLTWH(22, 21, 23, 24));
              expect(paragraph.text, 'Hey!');
              expect(paragraph.recognizedBreak.detectedBreakType,
                  TextRecognizedBreakType.values[5]);
              expect(paragraph.recognizedBreak.isPrefix, false);
              expect(paragraph.recognizedLanguages, hasLength(1));
              expect(paragraph.confidence, 0.5);
              expect(paragraph.words, hasLength(2));
            });
          });

          group('$DocumentTextWord', () {
            test('is valid after a valid reply', () async {
              final VisionDocumentText text =
                  await recognizer.processImage(image);

              DocumentTextWord word = text.blocks[0].paragraphs[0].words[0];
              // TODO(jackson): Use const Rect when available in minimum Flutter SDK
              // ignore: prefer_const_constructors
              expect(word.boundingBox, Rect.fromLTWH(14, 13, 15, 16));
              expect(word.text, 'Hey');
              expect(word.recognizedBreak, isNull);
              expect(word.recognizedLanguages, hasLength(1));
              expect(word.confidence, 0.0);
              expect(word.symbols, hasLength(3));

              word = text.blocks[0].paragraphs[0].words[1];
              // TODO(jackson): Use const Rect when available in minimum Flutter SDK
              // ignore: prefer_const_constructors
              expect(word.boundingBox, Rect.fromLTWH(18, 17, 19, 20));
              expect(word.text, '!');
              expect(word.recognizedBreak.detectedBreakType,
                  TextRecognizedBreakType.values[5]);
              expect(word.recognizedBreak.isPrefix, false);
              expect(word.recognizedLanguages, hasLength(0));
              expect(word.confidence, 0.1);
              expect(word.symbols, hasLength(0));
            });
          });

          group('$DocumentTextSymbol', () {
            test('is valid after a valid reply', () async {
              final VisionDocumentText text =
                  await recognizer.processImage(image);

              DocumentTextSymbol symbol =
                  text.blocks[0].paragraphs[0].words[0].symbols[0];
              // TODO(jackson): Use const Rect when available in minimum Flutter SDK
              // ignore: prefer_const_constructors
              expect(symbol.boundingBox, Rect.fromLTWH(2, 1, 3, 4));
              expect(symbol.text, 'H');
              expect(symbol.recognizedBreak, isNull);
              expect(symbol.recognizedLanguages, hasLength(1));
              expect(symbol.recognizedLanguages[0].languageCode, 'en');
              expect(symbol.confidence, 1);

              symbol = text.blocks[0].paragraphs[0].words[0].symbols[1];
              // TODO(jackson): Use const Rect when available in minimum Flutter SDK
              // ignore: prefer_const_constructors
              expect(symbol.boundingBox, Rect.fromLTWH(6, 5, 7, 8));
              expect(symbol.text, 'e');
              expect(symbol.recognizedBreak, isNull);
              expect(symbol.recognizedLanguages, hasLength(1));
              expect(symbol.recognizedLanguages[0].languageCode, 'hi');
              expect(symbol.confidence, 0.95);

              symbol = text.blocks[0].paragraphs[0].words[0].symbols[2];
              // TODO(jackson): Use const Rect when available in minimum Flutter SDK
              // ignore: prefer_const_constructors
              expect(symbol.boundingBox, Rect.fromLTWH(10, 9, 11, 12));
              expect(symbol.text, 'y');
              expect(symbol.recognizedBreak, isNull);
              expect(symbol.recognizedLanguages, hasLength(1));
              expect(symbol.recognizedLanguages[0].languageCode, 'fr');
              expect(symbol.confidence, 0.85);
            });
          });
        });
      });
    });
  });
}
