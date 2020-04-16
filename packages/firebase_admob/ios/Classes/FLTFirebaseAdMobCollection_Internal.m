#import "FLTFirebaseAdMobCollection_Internal.h"

@implementation FLTFirebaseAdMobCollection {
  NSMutableDictionary<id, id<NSCopying>> *_dictionary;
  dispatch_queue_t _lockQueue;
}

- (instancetype _Nonnull)init {
  self = [super init];
  if (self) {
    _dictionary = [[NSMutableDictionary alloc] init];
    _lockQueue = dispatch_queue_create("FLTThreadSafeCollection", DISPATCH_QUEUE_SERIAL);
  }
  return self;
}

- (void)addObject:(id _Nonnull)object forKey:(id)key {
  if (key && object) {
    dispatch_async(_lockQueue, ^{
      self->_dictionary[key] = object;
    });
  }
}

- (void)removeObjectForKey:(id)key {
  if (key != nil) {
    dispatch_async(_lockQueue, ^{
      [self->_dictionary removeObjectForKey:key];
    });
  }
}

- (id _Nullable)objectForKey:(id _Nonnull)key {
  id __block object = nil;
  dispatch_sync(_lockQueue, ^{
    object = _dictionary[key];
  });
  return object;
}

- (NSArray<id> *_Nonnull)allKeysForObject:(id _Nonnull)object {
  NSArray<id> __block *keys = nil;
  dispatch_sync(_lockQueue, ^{
    keys = [_dictionary allKeysForObject:object];
  });
  return keys;
}
@end
