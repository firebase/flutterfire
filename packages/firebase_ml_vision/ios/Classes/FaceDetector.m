// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTFirebaseMlVisionPlugin.h"

@import MLKitFaceDetection;

@interface FaceDetector ()
@property MLKFaceDetector *detector;
@end

@implementation FaceDetector
- (instancetype)initWithOptions:(NSDictionary *)options {
  self = [super init];
  if (self) {
    _detector = [MLKFaceDetector faceDetectorWithOptions:[FaceDetector parseOptions:options]];
  }
  return self;
}

- (void)handleDetection:(MLKVisionImage *)image result:(FlutterResult)result {
  [_detector
      processImage:image
        completion:^(NSArray<MLKFace *> *_Nullable faces, NSError *_Nullable error) {
          if (error) {
            [FLTFirebaseMlVisionPlugin handleError:error result:result];
            return;
          } else if (!faces) {
            result(@[]);
            return;
          }

          NSMutableArray *faceData = [NSMutableArray array];
          for (MLKFace *face in faces) {
            id smileProb = face.hasSmilingProbability ? @(face.smilingProbability) : [NSNull null];
            id leftProb =
                face.hasLeftEyeOpenProbability ? @(face.leftEyeOpenProbability) : [NSNull null];
            id rightProb =
                face.hasRightEyeOpenProbability ? @(face.rightEyeOpenProbability) : [NSNull null];

            NSDictionary *data = @{
              @"left" : @(face.frame.origin.x),
              @"top" : @(face.frame.origin.y),
              @"width" : @(face.frame.size.width),
              @"height" : @(face.frame.size.height),
              @"headEulerAngleY" : face.hasHeadEulerAngleY ? @(face.headEulerAngleY)
                                                           : [NSNull null],
              @"headEulerAngleZ" : face.hasHeadEulerAngleZ ? @(face.headEulerAngleZ)
                                                           : [NSNull null],
              @"smilingProbability" : smileProb,
              @"leftEyeOpenProbability" : leftProb,
              @"rightEyeOpenProbability" : rightProb,
              @"trackingId" : face.hasTrackingID ? @(face.trackingID) : [NSNull null],
              @"landmarks" : @{
                @"bottomMouth" : [FaceDetector getLandmarkPosition:face
                                                          landmark:MLKFaceLandmarkTypeMouthBottom],
                @"leftCheek" : [FaceDetector getLandmarkPosition:face
                                                        landmark:MLKFaceLandmarkTypeLeftCheek],
                @"leftEar" : [FaceDetector getLandmarkPosition:face
                                                      landmark:MLKFaceLandmarkTypeLeftEar],
                @"leftEye" : [FaceDetector getLandmarkPosition:face
                                                      landmark:MLKFaceLandmarkTypeLeftEye],
                @"leftMouth" : [FaceDetector getLandmarkPosition:face
                                                        landmark:MLKFaceLandmarkTypeMouthLeft],
                @"noseBase" : [FaceDetector getLandmarkPosition:face
                                                       landmark:MLKFaceLandmarkTypeNoseBase],
                @"rightCheek" : [FaceDetector getLandmarkPosition:face
                                                         landmark:MLKFaceLandmarkTypeRightCheek],
                @"rightEar" : [FaceDetector getLandmarkPosition:face
                                                       landmark:MLKFaceLandmarkTypeRightEar],
                @"rightEye" : [FaceDetector getLandmarkPosition:face
                                                       landmark:MLKFaceLandmarkTypeRightEye],
                @"rightMouth" : [FaceDetector getLandmarkPosition:face
                                                         landmark:MLKFaceLandmarkTypeMouthRight],
              },
              @"contours" : @{
                @"allPoints" : [FaceDetector getContourPoints:face contour:MLKFaceContourTypeFace],
                @"face" : [FaceDetector getContourPoints:face contour:MLKFaceContourTypeFace],
                @"leftEye" : [FaceDetector getContourPoints:face contour:MLKFaceContourTypeLeftEye],
                @"leftEyebrowBottom" :
                    [FaceDetector getContourPoints:face
                                           contour:MLKFaceContourTypeLeftEyebrowBottom],
                @"leftEyebrowTop" :
                    [FaceDetector getContourPoints:face contour:MLKFaceContourTypeLeftEyebrowTop],
                @"lowerLipBottom" :
                    [FaceDetector getContourPoints:face contour:MLKFaceContourTypeLowerLipBottom],
                @"lowerLipTop" : [FaceDetector getContourPoints:face
                                                        contour:MLKFaceContourTypeLowerLipTop],
                @"noseBottom" : [FaceDetector getContourPoints:face
                                                       contour:MLKFaceContourTypeNoseBottom],
                @"noseBridge" : [FaceDetector getContourPoints:face
                                                       contour:MLKFaceContourTypeNoseBridge],
                @"rightEye" : [FaceDetector getContourPoints:face
                                                     contour:MLKFaceContourTypeRightEye],
                @"rightEyebrowBottom" :
                    [FaceDetector getContourPoints:face
                                           contour:MLKFaceContourTypeRightEyebrowBottom],
                @"rightEyebrowTop" :
                    [FaceDetector getContourPoints:face contour:MLKFaceContourTypeRightEyebrowTop],
                @"upperLipBottom" :
                    [FaceDetector getContourPoints:face contour:MLKFaceContourTypeUpperLipBottom],
                @"upperLipTop" : [FaceDetector getContourPoints:face
                                                        contour:MLKFaceContourTypeUpperLipTop],
              }
            };

            [faceData addObject:data];
          }

          result(faceData);
        }];
}

+ (id)getLandmarkPosition:(MLKFace *)face landmark:(MLKFaceLandmarkType)landmarkType {
  MLKFaceLandmark *landmark = [face landmarkOfType:landmarkType];
  if (landmark) {
    return @[ @(landmark.position.x), @(landmark.position.y) ];
  }

  return [NSNull null];
}

+ (id)getContourPoints:(MLKFace *)face contour:(MLKFaceContourType)contourType {
  MLKFaceContour *contour = [face contourOfType:contourType];
  if (contour) {
    NSArray<MLKVisionPoint *> *contourPoints = contour.points;
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[contourPoints count]];
    for (int i = 0; i < [contourPoints count]; i++) {
      MLKVisionPoint *point = [contourPoints objectAtIndex:i];
      [result insertObject:@[ @(point.x), @(point.y) ] atIndex:i];
    }
    return [result copy];
  }

  return [NSNull null];
}

+ (MLKFaceDetectorOptions *)parseOptions:(NSDictionary *)optionsData {
  MLKFaceDetectorOptions *options = [[MLKFaceDetectorOptions alloc] init];

  NSNumber *enableClassification = optionsData[@"enableClassification"];
  if (enableClassification.boolValue) {
    options.classificationMode = MLKFaceDetectorClassificationModeAll;
  } else {
    options.classificationMode = MLKFaceDetectorClassificationModeNone;
  }

  NSNumber *enableLandmarks = optionsData[@"enableLandmarks"];
  if (enableLandmarks.boolValue) {
    options.landmarkMode = MLKFaceDetectorLandmarkModeAll;
  } else {
    options.landmarkMode = MLKFaceDetectorLandmarkModeNone;
  }

  NSNumber *enableContours = optionsData[@"enableContours"];
  if (enableContours.boolValue) {
    options.contourMode = MLKFaceDetectorContourModeAll;
  } else {
    options.contourMode = MLKFaceDetectorContourModeNone;
  }

  NSNumber *enableTracking = optionsData[@"enableTracking"];
  options.trackingEnabled = enableTracking.boolValue;

  NSNumber *minFaceSize = optionsData[@"minFaceSize"];
  options.minFaceSize = [minFaceSize doubleValue];

  NSString *mode = optionsData[@"mode"];
  if ([mode isEqualToString:@"accurate"]) {
    options.performanceMode = MLKFaceDetectorPerformanceModeAccurate;
  } else if ([mode isEqualToString:@"fast"]) {
    options.performanceMode = MLKFaceDetectorPerformanceModeFast;
  }

  return options;
}
@end
