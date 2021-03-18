// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTFirebaseMlVisionPlugin.h"

@import MLKitTextRecognition;

@interface TextRecognizer ()
@property MLKTextRecognizer *recognizer;
@end

@implementation TextRecognizer
- (instancetype)initWithOptions:(NSDictionary *)options {
  self = [super init];
  if (self) {
    _recognizer = [MLKTextRecognizer textRecognizer];
  }
  return self;
}

- (void)handleDetection:(MLKVisionImage *)image result:(FlutterResult)result {
  [_recognizer processImage:image
                 completion:^(MLKText *_Nullable visionText, NSError *_Nullable error) {
                   if (error) {
                     [FLTFirebaseMlVisionPlugin handleError:error result:result];
                     return;
                   } else if (!visionText) {
                     result(@{@"text" : @"", @"blocks" : @[]});
                     return;
                   }

                   NSMutableDictionary *visionTextData = [NSMutableDictionary dictionary];
                   visionTextData[@"text"] = visionText.text;

                   NSMutableArray *allBlockData = [NSMutableArray array];
                   for (MLKTextBlock *block in visionText.blocks) {
                     NSMutableDictionary *blockData = [NSMutableDictionary dictionary];

                     [self addData:blockData
                         cornerPoints:block.cornerPoints
                                frame:block.frame
                            languages:block.recognizedLanguages
                                 text:block.text];

                     NSMutableArray *allLineData = [NSMutableArray array];
                     for (MLKTextLine *line in block.lines) {
                       NSMutableDictionary *lineData = [NSMutableDictionary dictionary];

                       [self addData:lineData
                           cornerPoints:line.cornerPoints
                                  frame:line.frame
                              languages:line.recognizedLanguages
                                   text:line.text];

                       NSMutableArray *allElementData = [NSMutableArray array];
                       for (MLKTextElement *element in line.elements) {
                         NSMutableDictionary *elementData = [NSMutableDictionary dictionary];

                         [self addData:elementData
                             cornerPoints:element.cornerPoints
                                    frame:element.frame
                                languages:[NSArray new]
                                     text:element.text];

                         [allElementData addObject:elementData];
                       }

                       lineData[@"elements"] = allElementData;
                       [allLineData addObject:lineData];
                     }

                     blockData[@"lines"] = allLineData;
                     [allBlockData addObject:blockData];
                   }

                   visionTextData[@"blocks"] = allBlockData;
                   result(visionTextData);
                 }];
}

- (void)addData:(NSMutableDictionary *)addTo
    cornerPoints:(NSArray<NSValue *> *)cornerPoints
           frame:(CGRect)frame
       languages:(NSArray<MLKTextRecognizedLanguage *> *)languages
            text:(NSString *)text {
  __block NSMutableArray<NSArray *> *points = [NSMutableArray array];

  for (NSValue *point in cornerPoints) {
    [points addObject:@[ @(point.CGPointValue.x), @(point.CGPointValue.y) ]];
  }

  __block NSMutableArray<NSDictionary *> *allLanguageData = [NSMutableArray array];
  for (MLKTextRecognizedLanguage *language in languages) {
    [allLanguageData addObject:@{
      @"languageCode" : language.languageCode ? language.languageCode : [NSNull null]
    }];
  }

  [addTo addEntriesFromDictionary:@{
    @"confidence" : [NSNull null],
    @"points" : points,
    @"left" : @(frame.origin.x),
    @"top" : @(frame.origin.y),
    @"width" : @(frame.size.width),
    @"height" : @(frame.size.height),
    @"recognizedLanguages" : allLanguageData,
    @"text" : text,
  }];
}
@end
