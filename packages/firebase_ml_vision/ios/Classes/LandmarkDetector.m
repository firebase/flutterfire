// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTFirebaseMlVisionPlugin.h"

@interface LandmarkDetector ()
@property FIRVisionCloudLandmarkDetector *detector;
@end

@implementation LandmarkDetector
- (instancetype)initWithVision:(FIRVision *)vision options:(NSDictionary *)options {
  self = [super init];
  if (self) {
    _detector = [vision cloudLandmarkDetectorWithOptions:[LandmarkDetector parseOptions:options]];
  }
  return self;
}

- (void)handleDetection:(FIRVisionImage *)image result:(FlutterResult)result {
  [_detector
      detectInImage:image
        completion:^(NSArray<FIRVisionCloudLandmark *> *_Nullable landmarks, NSError *_Nullable error) {
          if (error) {
            [FLTFirebaseMlVisionPlugin handleError:error result:result];
            return;
          } else if (!landmarks) {
            result(@[]);
            return;
          }

          NSMutableArray *landmarkData = [NSMutableArray array];
          for (FIRVisionCloudLandmark *landmark in landmarks) {
            NSArray<FIRVisionLatitudeLongitude *> *visionLocations = landmark.locations;
            NSMutableArray *locations = [[NSMutableArray alloc] initWithCapacity:[visionLocations count]];
            for (int i = 0; i < [visionLocations count]; i++) {
              FIRVisionLatitudeLongitude *location = [visionLocations objectAtIndex:i];
              NSDictionary *locationDictionary = @{
                @"lat" : location.latitude,
                @"lng" : location.longitude
              };
              [locations insertObject:locationDictionary atIndex:i];
            }

            NSDictionary *data = @{
              @"left" : @(landmark.frame.origin.x),
              @"top" : @(landmark.frame.origin.y),
              @"width" : @(landmark.frame.size.width),
              @"height" : @(landmark.frame.size.height),
              @"confidence" : landmark.confidence,
              @"entityId" : landmark.entityId,
              @"landmark" : landmark.landmark,
              @"locations" : locations
            };

            [landmarkData addObject:data];
          }

          result(landmarkData);
        }];
}

+ (FIRVisionCloudDetectorOptions *)parseOptions:(NSDictionary *)optionsData {
  FIRVisionCloudDetectorOptions *options = [[FIRVisionCloudDetectorOptions alloc] init];
  NSNumber *maxResults = optionsData[@"maxResults"];
  options.maxResults = [maxResults integerValue];

  NSString *mode = optionsData[@"modelType"];
  options.modelType = FIRVisionCloudModelTypeStable;
  if ([mode isEqualToString:@"latest_model"]) {
    options.modelType = FIRVisionCloudModelTypeLatest;
  }

  return options;
}
@end
