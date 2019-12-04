#import "FirebaseMlVisionPlugin.h"

@import FirebaseMLCommon;

@interface RemoteVisionEdgeDetector ()
@property FIRVisionImageLabeler *labeler;
@end

@implementation RemoteVisionEdgeDetector

- (instancetype)initWithVision:(FIRVision *)vision options:(NSDictionary *)options {
  self = [super init];
  if (self) {
    FIRRemoteModel *remoteModel =
    [[FIRModelManager modelManager] remoteModelWithName:options[@"dataset"]];
    if (remoteModel == nil) {
      FIRModelDownloadConditions *conditions =
      [[FIRModelDownloadConditions alloc] initWithAllowsCellularAccess:YES
                                           allowsBackgroundDownloading:YES];
      FIRRemoteModel *remoteModel = [[FIRRemoteModel alloc] initWithName:options[@"dataset"]
                                                      allowsModelUpdates:YES
                                                       initialConditions:conditions
                                                        updateConditions:conditions];
      [[FIRModelManager modelManager] registerRemoteModel:remoteModel];
      [[FIRModelManager modelManager] downloadRemoteModel:remoteModel];
      _labeler = [[FIRVision vision]
                  onDeviceAutoMLImageLabelerWithOptions:[RemoteVisionEdgeDetector parseOptions:options]];
    } else {
      Boolean isModelDownloaded =
      [[FIRModelManager modelManager] isRemoteModelDownloaded:remoteModel];
      if (isModelDownloaded == true) {
        _labeler = [[FIRVision vision]
                    onDeviceAutoMLImageLabelerWithOptions:[RemoteVisionEdgeDetector parseOptions:options]];
      } else {
        [[FIRModelManager modelManager] downloadRemoteModel:remoteModel];
        _labeler = [[FIRVision vision]
                    onDeviceAutoMLImageLabelerWithOptions:[RemoteVisionEdgeDetector parseOptions:options]];
      }
    }
  }
  return self;
}

+ (FIRVisionOnDeviceAutoMLImageLabelerOptions *)parseOptions:(NSDictionary *)optionsData {
  NSNumber *conf = optionsData[@"confidenceThreshold"];

  FIRVisionOnDeviceAutoMLImageLabelerOptions *options =
  [[FIRVisionOnDeviceAutoMLImageLabelerOptions alloc] initWithRemoteModelName:dataset
                                                               localModelName:nil];
  options.confidenceThreshold = [conf floatValue];

  return options;
}

+ (FIRAutoMLLocalModel *)modelForName:(NSString *)name {
  FIRRemoteModel *remoteModel = [[FIRModelManager modelManager] remoteModelWithName:modelName];
  if (remoteModel == nil) {
    FIRModelDownloadConditions *conditions =
    [[FIRModelDownloadConditions alloc] initWithAllowsCellularAccess:YES
                                         allowsBackgroundDownloading:YES];
    FIRRemoteModel *remoteModel = [[FIRRemoteModel alloc] initWithName:modelName
                                                    allowsModelUpdates:YES
                                                     initialConditions:conditions
                                                      updateConditions:conditions];
    [[FIRModelManager modelManager] registerRemoteModel:remoteModel];
    [[FIRModelManager modelManager] downloadRemoteModel:remoteModel];
  } else {
    Boolean isModelDownloaded =
    [[FIRModelManager modelManager] isRemoteModelDownloaded:remoteModel];
    if (isModelDownloaded == true) {
      result(@"Model Already Setup");
    } else {
      [[FIRModelManager modelManager] downloadRemoteModel:remoteModel];
      result(@"Model Setup Complete");
    }
  }
}

@end
