// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>

#import "Firebase/Firebase.h"

@interface FLTFirebaseMlVisionPlugin : NSObject <FlutterPlugin>
+ (void)handleError:(NSError *)error result:(FlutterResult)result;
@end

@protocol ModelManager
@required
+ (void)modelName:(NSString *)modelName result:(FlutterResult)result;
@optional
@end

@protocol Detector
@required
- (instancetype)initWithVision:(FIRVision *)vision options:(NSDictionary *)options;
- (void)handleDetection:(FIRVisionImage *)image result:(FlutterResult)result;
@optional
@end

@interface BarcodeDetector : NSObject <Detector>
@end

@interface FaceDetector : NSObject <Detector>
@end

@interface TextRecognizer : NSObject <Detector>
@end

@interface ImageLabeler : NSObject <Detector>
@property FIRVisionImageLabeler *labeler;
@end

@interface LocalVisionEdgeDetector : ImageLabeler
@end

@interface RemoteVisionEdgeDetector : ImageLabeler
@end
