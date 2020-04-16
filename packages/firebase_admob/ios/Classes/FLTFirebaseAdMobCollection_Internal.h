#import <Foundation/Foundation.h>
#import "FLTAd_Internal.h"
#import "FLTFirebaseAdMobPlugin.h"

@protocol FLTAd;
@protocol FLTNativeAdFactory;

@interface FLTFirebaseAdMobCollection<KeyType, ObjectType> : NSObject
- (void)addObject:(ObjectType _Nonnull)object forKey:(KeyType <NSCopying> _Nonnull)key;
- (void)removeObjectForKey:(KeyType _Nonnull)key;
- (id _Nullable)objectForKey:(KeyType _Nonnull)key;
- (NSArray<KeyType> *_Nonnull)allKeysForObject:(ObjectType _Nonnull)object;
@end
