#import "FirebaseMlVisionPlugin.h"

@import FirebaseMLCommon;

@implementation LocalVisionEdgeDetector

- (instancetype)initWithVision:(FIRVision *)vision options:(NSDictionary *)options {
  self = [super init];
  if (self) {
    self.labeler = [[FIRVision vision] onDeviceAutoMLImageLabelerWithOptions:[LocalVisionEdgeDetector parseOptions:options]];
  }
  return self;
}

+ (FIRVisionOnDeviceAutoMLImageLabelerOptions *)parseOptions:(NSDictionary *)optionsData {
  NSNumber *conf = optionsData[@"confidenceThreshold"];

  FIRVisionOnDeviceAutoMLImageLabelerOptions *options =
  [[FIRVisionOnDeviceAutoMLImageLabelerOptions alloc] initWithLocalModel:[LocalVisionEdgeDetector modelForName:@""]];
  options.confidenceThreshold = [conf floatValue];

  return options;
}

+ (FIRAutoMLLocalModel *)modelForName:(NSString *)name {
  NSString *pathStart = @"Frameworks/App.framework/flutter_assets/assets/";
  NSString *datasetAppended = [pathStart stringByAppendingString:name];
  NSString *finalPath = [datasetAppended stringByAppendingString:@"/manifest.json"];
  NSString *manifestPath = [[NSBundle mainBundle] pathForResource:finalPath ofType:nil];
  return [[FIRAutoMLLocalModel alloc] initWithManifestPath:manifestPath];
}
@end
