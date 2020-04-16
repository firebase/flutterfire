#import "FLTAdCollection_Internal.h"

@implementation FLTAdCollection {
  NSMutableDictionary<NSNumber *, id<FLTAd>> *_ads;
  dispatch_queue_t _lockQueue;
}

- (nonnull instancetype)init {
  self = [super init];
  if (self) {
    _ads = [[NSMutableDictionary alloc] init];
    _lockQueue = dispatch_queue_create("FLTAdCollection", DISPATCH_QUEUE_SERIAL);
  }
  return self;
}

- (void)addAd:(__kindof id<FLTAd> _Nonnull)ad forReferenceId:(NSNumber *_Nonnull)referenceId {
  if (referenceId && ad) {
    dispatch_async(_lockQueue, ^{
      self->_ads[referenceId] = ad;
    });
  }
}

- (void)removeAdWithReferenceId:(NSNumber *_Nonnull)referenceId {
  if (referenceId != nil) {
    dispatch_async(_lockQueue, ^{
      [self->_ads removeObjectForKey:referenceId];
    });
  }
}

- (__kindof id<FLTAd> _Nullable)adForReferenceId:(NSNumber *_Nonnull)referenceId {
  id<FLTAd> __block ad = nil;
  dispatch_sync(_lockQueue, ^{
    ad = _ads[referenceId];
  });
  return ad;
}

- (NSNumber *_Nullable)referenceIdForAd:(id<FLTAd> _Nonnull)ad {
  NSNumber *__block referenceId = nil;
  dispatch_sync(_lockQueue, ^{
    referenceId = [_ads allKeysForObject:ad][0];
  });
  return referenceId;
}
@end
