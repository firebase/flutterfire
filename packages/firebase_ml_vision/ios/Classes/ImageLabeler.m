// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTFirebaseMlVisionPlugin.h"

@import MLKitImageLabelingCommon;
@import MLKitImageLabeling;

@interface ImageLabeler ()
@property MLKImageLabeler *labeler;
@end

@implementation ImageLabeler
- (instancetype)initWithOptions:(NSDictionary *)options {
  self = [super init];
  if (self) {
    _labeler = [MLKImageLabeler imageLabelerWithOptions:[ImageLabeler parseOptions:options]];
  }
  return self;
}

- (void)handleDetection:(MLKVisionImage *)image result:(FlutterResult)result {
  [_labeler processImage:image
              completion:^(NSArray<MLKImageLabel *> *_Nullable labels, NSError *_Nullable error) {
                if (error) {
                  [FLTFirebaseMlVisionPlugin handleError:error result:result];
                  return;
                } else if (!labels) {
                  result(@[]);
                }

                NSMutableArray *labelData = [NSMutableArray array];
                for (MLKImageLabel *label in labels) {
                  NSDictionary *data = @{
                    @"confidence" : @(label.confidence),
                    @"entityID" : @(label.index),
                    @"text" : label.text,
                  };
                  [labelData addObject:data];
                }

                result(labelData);
              }];
}

+ (MLKImageLabelerOptions *)parseOptions:(NSDictionary *)optionsData {
  NSNumber *conf = optionsData[@"confidenceThreshold"];

  MLKImageLabelerOptions *options = [MLKImageLabelerOptions new];
  options.confidenceThreshold = conf;

  return options;
}

@end
