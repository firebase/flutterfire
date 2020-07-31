// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTFirebaseMlVisionPlugin.h"

@interface DocumentTextRecognizer ()
@property FIRVisionDocumentTextRecognizer *recognizer;
@end

@implementation DocumentTextRecognizer
- (instancetype)initWithVision:(FIRVision *)vision options:(NSDictionary *)options {
  self = [super init];
  if (self) {
    _recognizer = [vision cloudDocumentTextRecognizer];
  }
  return self;
}

- (void)handleDetection:(FIRVisionImage *)image result:(FlutterResult)result {
  [_recognizer processImage:image
                 completion:^(FIRVisionDocumentText *_Nullable visionDocumentText,
                              NSError *_Nullable error) {
                   if (error) {
                     [FLTFirebaseMlVisionPlugin handleError:error result:result];
                     return;
                   } else if (!visionDocumentText) {
                     result(@{@"text" : @"", @"blocks" : @[]});
                     return;
                   }

                   NSMutableDictionary *visionDocumentTextData = [NSMutableDictionary dictionary];
                   visionDocumentTextData[@"text"] = visionDocumentText.text;

                   NSMutableArray *allBlockData = [NSMutableArray array];
                   for (FIRVisionDocumentTextBlock *block in visionDocumentText.blocks) {
                     NSMutableDictionary *blockData = [NSMutableDictionary dictionary];

                     [self addData:blockData
                                   frame:block.frame
                              confidence:block.confidence
                         recognizedBreak:block.recognizedBreak
                               languages:block.recognizedLanguages
                                    text:block.text];

                     NSMutableArray *allParagraphData = [NSMutableArray array];
                     for (FIRVisionDocumentTextParagraph *paragraph in block.paragraphs) {
                       NSMutableDictionary *paragraphData = [NSMutableDictionary dictionary];

                       [self addData:paragraphData
                                     frame:paragraph.frame
                                confidence:paragraph.confidence
                           recognizedBreak:paragraph.recognizedBreak
                                 languages:paragraph.recognizedLanguages
                                      text:paragraph.text];

                       NSMutableArray *allWordData = [NSMutableArray array];
                       for (FIRVisionDocumentTextWord *word in paragraph.words) {
                         NSMutableDictionary *wordData = [NSMutableDictionary dictionary];

                         [self addData:wordData
                                       frame:word.frame
                                  confidence:word.confidence
                             recognizedBreak:word.recognizedBreak
                                   languages:word.recognizedLanguages
                                        text:word.text];

                         NSMutableArray *allSymbolData = [NSMutableArray array];
                         for (FIRVisionDocumentTextSymbol *symbol in word.symbols) {
                           NSMutableDictionary *symbolData = [NSMutableDictionary dictionary];

                           [self addData:symbolData
                                         frame:symbol.frame
                                    confidence:symbol.confidence
                               recognizedBreak:symbol.recognizedBreak
                                     languages:symbol.recognizedLanguages
                                          text:symbol.text];
                           [allSymbolData addObject:symbolData];
                         }
                         wordData[@"symbols"] = allSymbolData;
                         [allWordData addObject:wordData];
                       }
                       paragraphData[@"words"] = allWordData;
                       [allParagraphData addObject:paragraphData];
                     }
                     blockData[@"paragraphs"] = allParagraphData;
                     [allBlockData addObject:blockData];
                   }
                   visionDocumentTextData[@"blocks"] = allBlockData;
                   result(visionDocumentTextData);
                 }];
}

- (void)addData:(NSMutableDictionary *)addTo
              frame:(CGRect)frame
         confidence:(NSNumber *)confidence
    recognizedBreak:(FIRVisionTextRecognizedBreak *)recognizedBreak
          languages:(NSArray<FIRVisionTextRecognizedLanguage *> *)languages
               text:(NSString *)text {
  __block NSMutableArray<NSDictionary *> *allLanguageData = [NSMutableArray array];
  for (FIRVisionTextRecognizedLanguage *language in languages) {
    [allLanguageData addObject:@{
      @"languageCode" : language.languageCode ? language.languageCode : [NSNull null]
    }];
  }

  if (recognizedBreak != nil) {
    NSMutableDictionary *recognizedBreakDictionary = [NSMutableDictionary dictionary];
    [recognizedBreakDictionary addEntriesFromDictionary:@{
      @"detectedBreakType" : [NSNumber numberWithUnsignedInteger:recognizedBreak.type],
      @"detectedBreakPrefix" : @(recognizedBreak.isPrefix),
    }];
    [addTo addEntriesFromDictionary:@{
      @"recognizedBreak" : recognizedBreakDictionary,
    }];
  } else {
    [addTo addEntriesFromDictionary:@{
      @"recognizedBreak" : [NSNull null],
    }];
  }

  [addTo addEntriesFromDictionary:@{
    @"left" : @(frame.origin.x),
    @"top" : @(frame.origin.y),
    @"width" : @(frame.size.width),
    @"height" : @(frame.size.height),
    @"confidence" : confidence ? confidence : [NSNull null],
    @"recognizedLanguages" : allLanguageData,
    @"text" : text,
  }];
}
@end
